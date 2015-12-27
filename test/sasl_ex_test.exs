defmodule SaslExTest do
  use ExUnit.Case
  doctest SaslEx

  # from http://docs.couchbase.com/developer/dev-guide-3.0/sasl.html
  @list_mechanisms << 
    0x80                :: size(8),
    0x20                :: size(8),
    0x0000              :: size(16),
    0x00                :: size(8),
    0x00                :: size(8),
    0x0000              :: size(16),
    0x00000000          :: size(32),
    0x00000000          :: size(32),
    0x0000000000000000  :: size(64),
  >>

  test "SaslEx can parse list_mechanisms correctly" do
    message = SaslEx.from_bytes @list_mechanisms
    assert message.magic          == 0x80
    assert message.opcode         == 0x20
    assert message.key_length     == 0x0
    assert message.extra_length   == 0x0
    assert message.data_type      == 0x0
    assert message.v_bucket       == 0x0
    assert message.total_body     == 0x0
    assert message.opaque         == 0x0
    assert message.cas            == 0x0
    assert message.payload        == ""
  end

  test "SaslEx handles remaining bytes correctly" do
    bytes = @list_mechanisms <> "JasonWasHere"
    message = SaslEx.from_bytes bytes
    assert message.payload == "JasonWasHere"
  end

end

