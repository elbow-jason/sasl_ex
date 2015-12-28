defmodule SaslExTest do
  use ExUnit.Case
  doctest SaslEx

  # from http://docs.couchbase.com/developer/dev-guide-3.0/sasl.html
  @bytes << 
    0x1 :: size(8),
    0x2 :: size(8),
    0x3 :: size(16),
    0x4 :: size(8),
    0x5 :: size(8),
    0x6 :: size(16),
    0x7 :: size(32),
    0x8 :: size(32),
    0x9 :: size(64),
  >>

  test "from_bytes can parse bytes correctly" do
    message = SaslEx.from_bytes @bytes
    assert message.magic          == 0x1
    assert message.opcode         == 0x2
    assert message.key_length     == 0x3
    assert message.extra_length   == 0x4
    assert message.data_type      == 0x5
    assert message.v_bucket       == 0x6
    assert message.total_body     == 0x7
    assert message.opaque         == 0x8
    assert message.cas            == 0x9
    assert message.payload        == ""
  end

  test "from_bytes handles remaining bytes correctly" do
    bytes = @bytes <> "JasonWasHere"
    message = SaslEx.from_bytes bytes
    assert message.payload == "JasonWasHere"
  end

  test "to_bytes handles bytes and payloads correctly" do
    expected = "abcdefghijklmnopqrstuvwx1234"
    sasl = %SaslEx{
      magic:        "a",              
      opcode:       "b",               
      key_length:   "cd",                   
      extra_length: "e",                     
      data_type:    "f",                  
      v_bucket:     "gh",                 
      total_body:   "ijkl",                   
      opaque:       "mnop",               
      cas:          "qrstuvwx",            
      payload:      "1234",                
    }
    assert SaslEx.to_bytes(sasl) == expected
  end 

end

