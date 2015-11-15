defmodule SaslEx.Command do
  alias SaslEx.Field
  alias SaslEx.Command
  alias SaslEx.Codes

  defstruct [
    magic:        0x00,
    opcode:       0x00,
    key_length:   0x00,
    extra_length: 0x00,
    data_type:    0x00,
    vbucket:      0x00,
    total_body:   0x00,
    opaque:       0x00,
    cas:          0x00,
    payload:        [],
  ]

  @ordered_fields ~w(
    magic           opcode      key_length
    extra_length    data_type   vbucket
    total_body      opaque      cas
  )a

  def to_fields(%Command{} = command) do
    func = fn field_name -> to_field(field_name, command) end
    Enum.map(@ordered_fields, func) ++ command.payload
  end

  defp to_field(field_name, command) do
    apply(SaslEx.Fields, field_name, command[field_name])
  end

  def list_mechanisms do
    %Command{
      magic:  Codes.magic_request,  #(0)    : 0x80                (Request)
      opcode: 0x20,
    } |> to_fields
  end

  def supports_plain_and_cram_md5 do
    %Command{
      magic:      Codes.magic_response,         #(0): 0x81 (Response)
      opcode:     Codes.opcode_list_mechanisms, #(1): 0x20 (SASL List Mechanisms)
      total_body: 0x0000000D,     #(8-11) : 0x0000000D          (14)
      payload:    [Fields.mechanisms] #(24-37): "PLAIN CRAM-MD5"
    }
    [
      %Field{key: :magic,        size: 8,   value: 0x81},           
      %Field{key: :opcode,       size: 8,   value: 0x20},           #(1)    : 0x20                (SASL List Mechanisms)
      %Field{key: :key_length,   size: 16,  value: 0x00},           #(2,3)  : 0x0000              (field not used)
      %Field{key: :extra_length, size: 8,   value: 0x00},           #(4)    : 0x00                (field not used)
      %Field{key: :data_type,    size: 8,   value: 0x00},           #(5)    : 0x00                (field not used)
      %Field{key: :vbucket,      size: 16,  value: 0x00},           #(6,7)  : 0x0000              (field not used)
      %Field{key: :opaque,       size: 32,  value: 0x00},           #(12-15): 0x00000000
      %Field{key: :cas,          size: 48,  value: 0x00},           #(16-23): 0x0000000000000000  (field not used)
      #mechanisms,          
    ]
  end
end