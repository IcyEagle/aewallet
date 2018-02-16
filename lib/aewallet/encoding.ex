defmodule Aewallet.Encoding do
  @moduledoc """
  This module is responsible for encoding Compressed Public keys
  in Bech32. This implementation is from BIP-0173.
  """

  alias Aewallet.KeyPair

  @typedoc "Currency types for pubkey formatting"
  @type currency :: :ae | :btc

  @doc """
  Encodes a compressed public key to a human readable format.
  The formatting could be done using Aeternity or Bitcoin public key.

  The values for the `currency` are:

    * `:ae` - formates Aeternity pubkey
    * `:btc` - formates Bitcoin pubkey

  ## Examples
      iex> Aewallet.Encoding.encode(pubkey, :ae)
      "ae1qq04nuehhr26nz7ggtgaqq939f9hsaq5hrlhsjrlcg5wngpq4pzc968kfa8u"

      iex> Aewallet.Encoding.encode(pubkey, :btc)
      "btc1qq04nuehhr26nz7ggtgaqq939f9hsaq5hrlhsjrlcg5wngpq4pzc963alrmy"
  """
  @spec encode(binary(), currency()) :: String.t()
  def encode(pubkey, currency) when byte_size(pubkey) == 33 do
    case currency do
      :ae ->
        SegwitAddr.encode("ae", 0, :binary.bin_to_list(pubkey))

      :btc ->
        SegwitAddr.encode("bc", 0, :binary.bin_to_list(pubkey))

      _ ->
        throw("The given currency '#{currency}' is not supported. Please use :ae or :btc")
    end
  end

  @doc """
  Decodes an encoded public key to it's compressed version

  ## Examples
      iex> Aewallet.Encoding.decode("ae1qq04nuehhr26nz7ggtgaqq939f9hsaq5hrlhsjrlcg5wngpq4pzc968kfa8u")
      {:ok, compressed_pubkey}
  """
  @spec decode(String.t()) :: tuple()
  def decode(encoded) do
    encoded
    |> SegwitAddr.decode()
    |> segwit_addr_decode()
  end

  defp segwit_addr_decode({:ok, {_prefix, _version, key}}) do
    {:ok, :binary.list_to_bin(key)}
  end
  defp segwit_addr_decode({:error, reason}) do
    {:error, reason}
  end

end
