defmodule SaslEx do
  alias SaslEx.Field

  def decode(field_list, bytes) do
    do_decode(field_list, bytes, [])
  end

  def byte_count(bytes) when bytes |> is_binary do
    byte_size(bytes)
  end
  def byte_count(list) when list |> is_list do
    Enum.reduce(list, 0, fn
      %Field{size: size}, acc    -> div(size, 8) + acc
      x, acc when x |> is_binary -> byte_size(x) + acc
    end)
  end

  def encode(field_list) do
    field_list
    |> Enum.map(&Field.to_bytes/1)
    |> Enum.join("")
  end

  def to_map(field_list) do
    Enum.reduce(%{}, fn item, acc -> Map.merge(acc, item |> Field.to_map) end)
  end

  defp do_decode([], "", decoded) do
    decoded |> Enum.reverse
  end
  defp do_decode(_, "", _) do
    raise "Ran out of bytes before decoding was finished. Not enough bytes."
  end
  defp do_decode([], _, _) do
    raise "Ran out of SaslEx.Fields before decoding was finished. Too many bytes."
  end
  defp do_decode([field | fields], bytes, prev_decoded) do
    {decoded, remaining_bytes} = Field.from_bytes(field, bytes)
    do_decode(fields, remaining_bytes, [decoded | prev_decoded])
  end

end
