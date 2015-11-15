defmodule SaslEx.Fields do
  alias SaslEx.Field
  
  def new_field(key, size, value) do
    %Field{key: key, size: size,  value: value}
  end

  @fields [
    {:magic,        0x00,   8 },
    {:opcode,       0x00,   8 },
    {:key_length,   0x00,  16 },
    {:extra_length, 0x00,   8 },
    {:data_type,    0x00,   8 },
    {:vbucket,      0x00,  16 },
    {:total_body,   0x00,  32 },
    {:opaque,       0x00,  32 },
    {:cas,          0x00,  48 },
  ]

  for {name, default, field_size} <- @fields do
    def unquote(name)(value \\ unquote(default)) do
      new_field(unquote(name), unquote(field_size), value)
    end
  end

  def mechanisms(value \\ "PLAIN CRAM-MD5") do
    value
    |> Field.from_bytes
    |> Map.put(:key, :mechanisms)
  end

end

