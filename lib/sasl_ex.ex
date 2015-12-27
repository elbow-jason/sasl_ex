defmodule SaslEx do

  defstruct [
    magic:             0x0, # (0)    : 0x80                (Request)
    opcode:            0x0, # (1)    : 0x20                (SASL List Mechanisms)
    key_length:        0x0, # (2,3)  : 0x0000              (field not used)
    extra_length:      0x0, # (4)    : 0x00                (field not used)
    data_type:         0x0, # (5)    : 0x00                (field not used)
    v_bucket:          0x0, # (6,7)  : 0x0000              (field not used)
    total_body:        0x0, # (8-11) : 0x00000000          (field not used)
    opaque:            0x0, # (12-15): 0x00000000
    cas:               0x0, # (16-23): 0x0000000000000000  (field not used)
    payload:           "",   # additional payloads
  ]

  def from_bytes(bytes) when bytes |> is_binary do
    byte_count = String.length(bytes)
    if byte_count < 24 do
      # NOTE:
      # do not include the bytes input string in the error message
      # it may contain sensitive data
      message = """
      A sasl message must be at least 24 bytes long.
      The input was #{byte_count} bytes long.
      """
      raise SaslError, message: message
    end

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
end
