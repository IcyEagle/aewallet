defmodule EnaclTest do
  use ExUnit.Case
  doctest Aewallet

  alias Aewallet.KeyPair
  alias Aewallet.Signing

  test "check validity of keys" do
    message = "data to be signed"
    %{public: pub, secret: sec} = Aewallet.KeyPair.generate_keypair()
    sign = Aewallet.Signing.sign(message, sec)
    assert true == Aewallet.Signing.verify(message, sign, pub)
  end
  
end
