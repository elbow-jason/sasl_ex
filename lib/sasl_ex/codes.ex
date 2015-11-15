defmodule SaslEx.Codes do

  
  @auth_token       "authtoken11"
  @plain            "PLAIN"
  @cram_md5         "CRAM-MD5"
  @space            " "
  @plain_and_cram   @plain <> @space <>  @cram_md5
  @plain_auth_token @plain <> @auth_token

  
  @magics %{
    protocol_binary_req:    0x80,
    protocol_binary_res:    0x81,
  }
  @opcodes %{
    sasl_list_mechanisms:   0x20,
    sasl_auth:              0x21,
  }
  @total_bodies %{
    plain_and_cram:    @plain_and_cram    |> String.length, # 14
    plain:             @plain             |> String.length, #  5
    plain_auth_token:  @plain_auth_token  |> String.length, # 16
   }
  @payloads: %{
    auth_token:        @auth_token        |> String.length, # 11
  }
  @key_lengths %{
    plain:             @plain             |> String.length,  # 5
  }
  @codes %{
    magic:          @magics,
    opcode:         @opcodes,
    total_body:     @total_bodies,
    payload:        @payloads,
  }

  def get_all do
    @codes
  end

  def get(key) do
    Map.get(@codes, key)
  end

  def get(key, subkey) do
    case Map.get(@codes, key, nil) do
      nil -> nil
      x   -> Map.get(x, subkey, nil)
    end
  end

end