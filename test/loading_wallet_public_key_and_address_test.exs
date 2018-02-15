defmodule LoadPublicKeyAndAddressTest do
  use ExUnit.Case
  doctest Aewallet

  alias Aewallet.Wallet, as: Wallet
  alias Aewallet.Cypher, as: Cypher

  test "validate master public key and address 1" do
    wallet_data = Wallet.load_wallet_file("test/test_wallets/wallet--2018-1-17-11-59-25", "password")
    assert wallet_data =
    {:ok, "day slot wink brother tip program motion kite trash excuse assume debris", :ae}

    {:ok, public_key} =
      Wallet.get_public_key("test/test_wallets/wallet--2018-1-17-11-59-25", "password")

    assert public_key ==
      Base.decode16!("0243C79213D6301FB19C50CEFCBBC2EE80CD53ACEFE9D4FB1FEE4E1DD3863F6430")

    {:ok, address} =
      Wallet.get_address("test/test_wallets/wallet--2018-1-17-11-59-25", "password")

    assert address == "ApgKtK5yi3npi3c48U53ESegbHSfsyYWWU"
  end

  test "validate master public key and address 2" do
    wallet_data = Wallet.load_wallet_file("test/test_wallets/wallet--2018-1-17-12-9-55", "password")
    assert wallet_data =
    {:ok, "bacon olympic warfare link crystal liberty mechanic husband age scan glance job", :btc}

    {:ok, public_key} =
      Wallet.get_public_key("test/test_wallets/wallet--2018-1-17-12-9-55", "password")

    assert public_key ==
      Base.decode16!("02C64160211603FB738BFD69AFEC4BC675D7AEDB7BDD06D5CC661D33EA3021AAD4")

    {:ok, address} =
      Wallet.get_address("test/test_wallets/wallet--2018-1-17-12-9-55", "password")

    assert address == "121jXTz93jqEqDSp2gSJCKTBvbWYWeJD8i"
  end

   test "validate master public key and address 3" do
    wallet_data = Wallet.load_wallet_file("test/test_wallets/wallet--2018-1-17-12-12-16", "password")
    assert wallet_data =
    {:ok, "dial prevent prize already actual hammer alarm warfare crunch recipe tide bind", :ae, "1234"}

    {:ok, public_key} =
      Wallet.get_public_key("test/test_wallets/wallet--2018-1-17-12-12-16", "password")

    assert public_key ==
      Base.decode16!("02169FE30E399CC4B6BF5CFCB8CD7091D462D5B50E8082C7D9C0A54080E77BE056")

    {:ok, address} =
      Wallet.get_address("test/test_wallets/wallet--2018-1-17-12-12-16", "password")

    assert address == "AsZ6sZxqJrD7WGYBURJnKpxdJKSfyjK1j9"
  end
end
