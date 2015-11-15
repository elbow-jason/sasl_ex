defmodule SaslEx.Field do
  alias SaslEx.Field

  defstruct [
    size:     0,
    key:      nil,
    value:    0,
  ]

  def from_bytes(data) do
    %Field{}
    |> Map.put(:size, byte_size(data) * 8)
    |> from_bytes(data)
    |> elem(0)
  end

  def from_bytes(%Field{key: key, size: field_size} = field, data) do
    from_bytes(key, field_size, data)
  end

  def from_bytes(key, field_size, data) do
    << value :: size(field_size), rest :: binary >> = data
    {%Field{key: key, size: field_size, value: value}, rest}
  end

  def to_bytes(%Field{value: value, size: field_size}) do
    << value :: size(field_size) >>
  end

  def to_map(%Field{key: key, value: value}) do
    Map.put(%{}, key, value)
  end

  def to_tuple(%Field{key: key, value: value}) do
    {key, value}
  end

  def into(%Field{key: key, value: value} = field, enum) do
    case enum do
      %{}                 -> Map.put(enum, key, value)
      x when x |> is_list -> x ++ [to_tuple(field)]
    end
  end

  def magic(value \\ 0x80) do
    %Field{key: :magic, size: 8,  value: value}
  end 

  def opcode(value \\ 0x20) do
    %Field{key: :opcode, size: 8, value: value}
  end

end