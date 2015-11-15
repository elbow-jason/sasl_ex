defmodule SaslExTest do
  use ExUnit.Case
  doctest SaslEx
  alias SaslEx.Field

  # base_fields taken from the examples at
  # http://docs.couchbase.com/developer/dev-guide-3.0/sasl.html

  @base_fields [
    %Field{key: :magic,          value: 0,  size: 8  },  #(0)    : 0x80                (Request)
    %Field{key: :opcode,         value: 0,  size: 8  },  #(1)    : 0x20                (SASL List Mechanisms)
    %Field{key: :key_length,     value: 0,  size: 16 },  #(2,3)  : 0x0000              (field not used)
    %Field{key: :extra_length,   value: 0,  size: 8  },  #(4)    : 0x00                (field not used)
    %Field{key: :data_type,      value: 0,  size: 8  },  #(5)    : 0x00                (field not used)
    %Field{key: :vbucket,        value: 0,  size: 16 },  #(6,7)  : 0x0000              (field not used)
    %Field{key: :total_body,     value: 0,  size: 32 },  #(8-11) : 0x00000000          (field not used)
    %Field{key: :opaque,         value: 0,  size: 32 },  #(12-15): 0x00000000
    %Field{key: :cas,            value: 0,  size: 48 },  #(16-23): 0x0000000000000000  (field not used)
  ]

  test "decode decodes a bytestring into a list of fields" do
    result = SaslEx.decode(@base_fields, "thing one thing two 22")
    assert length(result) == length(@base_fields)
    assert result |> hd == %Field{key: :magic, value: 116, size: 8}
    assert result |> List.last == %Field{key: :cas, value: 128056314311218, size: 48}
  end

  test "encode encodes a list of fields into a bytestring" do
    result = @base_fields
      |> SaslEx.encode
      #|> Enum.map(fn item -> %{item | value: 111} end)
    assert result == <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>
  end

  test "byte_count returns the number of bytes in a list of Fields" do
    result = @base_fields |> SaslEx.byte_count
    assert result == 22
  end

  test "byte_count returns the number of bytes of a list of strings" do
    result = ["mic", "check"] |> SaslEx.byte_count
    assert result == 8 
  end

  test "byte_count returns the number of bytes of a string" do
    result = "this thing on??" |> SaslEx.byte_count
    assert result == 15
  end

end

defmodule SaslEx.FieldTest do
  use ExUnit.Case
  doctest SaslEx.Field
  alias SaslEx.Field

  test "to_bytes outputs bytes" do
    assert %Field{key: :letter_k, value: 75,  size: 8} |> Field.to_bytes == "K"
  end

  test "from_bytes/1 outputs a %SaslEx.Field{} with the correct value" do
    {result, remaining} = %Field{key: :letter_k, size: 8} |> Field.from_bytes("K")
    assert remaining  == ""
    assert result     == %Field{key: :letter_k, size: 8, value: 75}
  end

  test "from_bytes/3 outputs a %SaslEx.Field{} correctly" do
    {result, remaining} = Field.from_bytes(:hooah, 32,"ARMY_strong")
    assert remaining  == "_strong"
    assert result     ==  %Field{key: :hooah, size: 32, value: 1095912793}
  end

  test "to_map/1 returns a map with the key as the key and the value as the value" do
    result = "K"
      |> Field.from_bytes
      |> Map.put(:key, :letter_k)
      |> Field.to_map
    assert result == %{letter_k: 75}
  end

  test "to_tuple/1 returns a tuple with {key, value} format" do
    result = "K"
      |> Field.from_bytes
      |> Map.put(:key, :letter_k)
      |> Field.to_tuple
    assert result == {:letter_k, 75}
  end

  test "into/2 returns a list when given a list" do
    field = %Field{key: :name, value: 123, size: 16}
    result = Field.into(field, [age: 111])
    assert result == [age: 111, name: 123]
  end

end




