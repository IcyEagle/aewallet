defmodule Bech32DormattingTest do
  use ExUnit.Case
  doctest Aewallet

  alias Aewallet.Encoding

  @valid_address [
    ["BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4", "0014751e76e8199196d454941c45d1b3a323f1433bd6"],
    ["tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7",
     "00201863143c14c5166804bd19203356da136c985678cd4d27a1b8c6329604903262"],
    ["bc1pw508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7k7grplx",
     "5128751e76e8199196d454941c45d1b3a323f1433bd6751e76e8199196d454941c45d1b3a323f1433bd6"],
    ["BC1SW50QA3JX3S", "6002751e"],
    ["bc1zw508d6qejxtdg4y5r3zarvaryvg6kdaj", "5210751e76e8199196d454941c45d1b3a323"],
    ["tb1qqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesrxh6hy",
     "0020000000c4a5cad46221b2a187905e5266362b99d5e91c6ce24d165dab93e86433"],
  ]

  @invalid_address [
    "tc1qw508d6qejxtdg4y5r3zarvary0c5xw7kg3g4ty",
    "bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t5",
    "BC13W508D6QEJXTDG4Y5R3ZARVARY0C5XW7KN40WF2",
    "bc1rw5uspcuh",
    "bc10w508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7kw5rljs90",
    "BC1QR508D6QEJXTDG4Y5R3ZARVARYV98GJ9P",
    "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sL5k7",
    "bc1zw508d6qejxtdg4y5r3zarvaryvqyzf3du",
    "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3pjxtptv",
    "bc1gmk9yu"
  ]

  test "valid addresses" do
    for [addr, hex] <- @valid_address do
      assert {:ok, {hrp, version, program}} = SegwitAddr.decode(addr)
      assert version != nil
      assert SegwitAddr.encode(hrp, version, program) == String.downcase(addr)
      assert SegwitAddr.to_script_pub_key(version, program) == hex
    end
  end

  test "invalid address" do
    for [addr, _hex] <- @invalid_address do
      assert {:error, _} = SegwitAddr.decode(addr)
    end
  end

  test "valid aeternity address" do
    assert {:ok,
            <<3, 235, 62, 102, 247, 26, 181, 49, 121, 8, 90, 58, 0, 22, 37, 73, 111, 14,
            130, 151, 31, 239, 9, 15, 248, 69, 29, 52, 4, 21, 8, 176, 93>>} =
      Aewallet.Encoding.decode("ae1qq04nuehhr26nz7ggtgaqq939f9hsaq5hrlhsjrlcg5wngpq4pzc968kfa8u")
  end

  test "invalid aeternity address" do
    assert {:error, "Invalid checksum"} =
      Aewallet.Encoding.decode("ae1qq04nuehhr26nz7ggtgaqq939f9hsaq5hrlhsjrlcg5wngpq4pzc968kfa8")
  end

  test "encode key" do
    key = <<2, 16, 79, 59, 182, 75, 40, 252, 211, 42, 44, 81, 19, 17, 224, 213, 54, 134,
      43, 119, 61, 145, 93, 120, 197, 205, 37, 199, 227, 2, 172, 252, 202>>
    assert "ae1qqggy7wakfv50e5e293g3xy0q65mgv2mh8kg467x9e5ju0ccz4n7v55dnf82" =
      Encoding.encode(key, :ae)
    assert "bc1qqggy7wakfv50e5e293g3xy0q65mgv2mh8kg467x9e5ju0ccz4n7v5ysz2ez" =
      Encoding.encode(key, :btc)
  end
end
