defmodule LoadPublicKeyAndAddressTest do
  use ExUnit.Case
  doctest Aewallet

  alias Aewallet.Wallet, as: Wallet
  alias Aewallet.Cypher, as: Cypher

  test "validate keypair 1" do
    {:ok, public_key} =
      Wallet.get_public_key("test/test_wallets/wallet--2018-6-11-14-13-40", "pass")

    assert public_key ==
      Base.decode16!("CA972C827479476650ADD1E2ABE4423F6B844B56CF111B3A8D01E6038CA80431")

    {:ok, private_key} =
      Wallet.get_private_key("test/test_wallets/wallet--2018-6-11-14-13-40", "pass")

    assert private_key ==
      Base.decode16!("3F656FB0072141A44CC6A5124C6962D8C9B05F39E2169F6053567465A45AD80CCA972C827479476650ADD1E2ABE4423F6B844B56CF111B3A8D01E6038CA80431")
  end

  test "validate keypair 2" do
    {:ok, public_key} =
      Wallet.get_public_key("test/test_wallets/wallet--2018-6-11-14-25-59", "pass")

    assert public_key ==
      Base.decode16!("AB72BDF6357A0C543E2CE9C136F49CFCFEC76008EB312366D0C37408C239F2F3")

    {:ok, private_key} =
      Wallet.get_private_key("test/test_wallets/wallet--2018-6-11-14-25-59", "pass")

    assert private_key ==
      Base.decode16!("4D11CA666EFEFE622D6013188F072537AD88E92C0692300685C25078E24B615EAB72BDF6357A0C543E2CE9C136F49CFCFEC76008EB312366D0C37408C239F2F3")
  end

   test "validate keypairo
 3" do
    {:ok, public_key} =
      Wallet.get_public_key("test/test_wallets/wallet--2018-6-11-14-27-39", "pass")

    assert public_key ==
      Base.decode16!("44018C5A75F39AB027872AB2017D881013A7F700C82B5790D8BEDCD7E28C45AD")

    {:ok, private_key} =
      Wallet.get_private_key("test/test_wallets/wallet--2018-6-11-14-27-39", "pass")

    assert private_key ==
      Base.decode16!("DD0D4DE7AE3319D8D24581864040DB6070905895D24A059072F6F358A675DBC244018C5A75F39AB027872AB2017D881013A7F700C82B5790D8BEDCD7E28C45AD")
  end
end
