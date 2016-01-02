defmodule SaslEx do
  @moduledoc """
  SaslEx is a library for encoding and decoding the sasl protocol.
  """

  @magic_request          128       # 0x80
  @magic_response         129       # 0x81
  @opcode_list_mechanism  32        # 0x20
  @opcode_authenticate    33        # 0x21
  @opcode_step            34        # 0x22
  @status_success         0         # 0x0000
  @plain                  "PLAIN"
  @cram_md5               "CRAM-MD5"
  @plain_and_cram_md5     "#{@plain} #{@cram_md5}"
  @authenticated          "Authenticated"

  defstruct [
    magic:             0x0, # (0)    : 0x00
    opcode:            0x0, # (1)    : 0x00
    key_length:        0x0, # (2,3)  : 0x0000
    extra_length:      0x0, # (4)    : 0x00
    data_type:         0x0, # (5)    : 0x00
    v_bucket:          0x0, # (6,7)  : 0x0000
    total_body:        0x0, # (8-11) : 0x00000000
    opaque:            0x0, # (12-15): 0x00000000
    cas:               0x0, # (16-23): 0x0000000000000000
    payload:           "",  # payloads are bytes (strings)
  ]

  def new do
    %SaslEx{}
  end

  def response do
    new |> magic_response
  end

  def request do
    new |> magic_request
  end

  def from_bytes(bytes) when bytes |> is_binary do
    validate_bytes!(bytes)

    <<  magic           :: size(8),
        opcode          :: size(8),
        key_length      :: size(16),
        extra_length    :: size(8),
        data_type       :: size(8),
        v_bucket        :: size(16),
        total_body      :: size(32),
        opaque          :: size(32),
        cas             :: size(64),
        payload         :: binary >> = bytes

    %SaslEx{
      magic:          magic,
      opcode:         opcode,
      key_length:     key_length,
      extra_length:   extra_length,
      data_type:      data_type,
      v_bucket:       v_bucket,
      total_body:     total_body,
      opaque:         opaque,
      cas:            cas,
      payload:        payload,
    }

  end

  def to_bytes(%SaslEx{} = saslex) do
    <<  saslex.magic           :: size(8),
        saslex.opcode          :: size(8),
        saslex.key_length      :: size(16),
        saslex.extra_length    :: size(8),
        saslex.data_type       :: size(8),
        saslex.v_bucket        :: size(16),
        saslex.total_body      :: size(32),
        saslex.opaque          :: size(32),
        saslex.cas             :: size(64),
        saslex.payload         :: binary,
    >>
  end

  def validate_bytes!(bytes) when bytes |> is_binary do
    byte_count = String.length(bytes)
    if byte_count < 24 do
      # NOTE:
      # do not include the bytes input string in the error message
      # it may contain sensitive data
      message = """
      A sasl message must be at least 24 bytes long.
      The input was #{byte_count} bytes long.
      """
      raise SaslEx.Error, message: message
    end
    true
  end

  def magic_request,          do: @magic_request
  def magic_response,         do: @magic_response
  def opcode_list_mechanisms, do: @opcode_list_mechanisms
  def opcode_auth,            do: @opcode_auth
  def opcode_step,            do: @opcode_step
  def status_success,         do: @status_success
  def plain,                  do: @plain
  def cram_md5,               do: @cram_md5
  def plain_and_cram_md5,     do: @plain_and_cram_md5
  def authenticated,          do: @authenticated

  def key_length(%SaslEx{} = sasl, value) when is_integer(value) do
    %{ sasl | key_length: value }
  end

  def total_body(%SaslEx{payload: payload} = sasl) do
    %{ sasl | total_body: byte_size(payload) }
  end

  def opcode_list_mechanisms(%SaslEx{} = sasl) do
    %{ sasl | opcode: @opcode_list_mechanisms }
  end

  def opcode_auth(%SaslEx{} = sasl) do
    %{ sasl | opcode: @opcode_auth }
  end

  def magic_request(%SaslEx{} = sasl) do
    %{ sasl | magic: @magic_request }
  end

  def magic_response(%SaslEx{} = sasl) do
    %{ sasl | magic: @magic_response }
  end

  def payload(%SaslEx{} = sals, key, value) when is_binary(key) and is_binary(value) do
    %{ sasl | payload: key <> value }
    |> key_length(byte_size(key))
    |> total_body
  end

  def payload(%SaslEx{payload: payload} = sasl, additional_payload) do 
    %{ sasl | payload: payload <> additional_payload } |> total_body
  end

  def cram_digest(key, data) do
    :crypto.md5_mac(key, data)
  end

end
