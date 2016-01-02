defmodule SaslEx.Request do
  alias SaslEx

  def list_mechanisms do
    SaslEx.request
    |> SaslEx.opcode_list_mechanism
  end 

  def plain_auth(auth_token) when auth_token |> is_binary do
    SaslEx.request
    |> SaslEx.opcode_auth
    |> SaslEx.payload("PLAIN", auth_token)
  end

end
