defmodule SaslEx.Response do
  alias SaslEx

  def type(bytes) when bytes |> is_binary do
    bytes
    |> SaslEx.from_bytes
    |> type
  end

  def type(%SaslEx{} = sasl) do
    case 
  end

  def list_mechanisms_plain do
    SaslEx.response
    |> SaslEx.opcode_list_mechanisms
    |> SaslEx.payload(SaslEx.plain)
  end

  def list_mechanisms_cram do
    SaslEx.response
    |> SaslEx.opcode_list_mechanisms
    |> SaslEx.payload(SaslEx.plain_and_cram_md5)
  end

  def authenticated do
    SaslEx.response
    |> SaslEx.payload(SaslEx.authenticated)
  end

  def cram_md5_authentication_request do
    SaslEx.response
    |> SaslEx.opcode_authenticate
    |> SaslEx.payload(SaslEx.cram_md5)
  end

  def cram_md5_authentication_challenge(salty) when salty |> is_binary do
    SaslEx.response
    |> SaslEx.opcode_authenticate
    |> SaslEx.payload(salt)
  end

  def authenticate(username, key, password) do
    hashed_password = SaslEx.cram_digest(key, password)
    SaslEx.response
    |> SaslEx.opcode_step
    |> SaslEx.payload(username, hashed_password)
  end

end
