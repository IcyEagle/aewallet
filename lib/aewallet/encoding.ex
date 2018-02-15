defmodule Aewallet.Encoding do
  @moduledoc """
  This module is responsible for encoding the Public keys
  in Bach32. This implementation is from BIP-0173.
  """

  alias Aewallet.KeyPair

  @typedoc "Wallet option value"
  @type currency :: :ae | :btc

  @doc """
  Encodes public key to a human readable format.

  ## Examples
      iex> Aewallet.Encoding.encode(compressed_pub_key, :ae)
      "ae1qq04nuehhr26nz7ggtgaqq939f9hsaq5hrlhsjrlcg5wngpq4pzc968kfa8u"

      iex> Aewallet.Encoding.encode(compressed_pub_key, :btc)
      "btc1qq04nuehhr26nz7ggtgaqq939f9hsaq5hrlhsjrlcg5wngpq4pzc963alrmy"
  """
  @spec encode(currency(), binary()) :: String.t()
  def encode(compressed_pub_key, currency) do
    case currency do
      :ae ->
        SegwitAddr.encode("ae", 0, :binary.bin_to_list(compressed_pub_key))

      :btc ->
        SegwitAddr.encode("btc", 0, :binary.bin_to_list(compressed_pub_key))

      _ ->
        throw("The given currency '#{currency}' is not supported. Please use :ae or :btc")
    end
  end

  @doc """
  Decodes a encoded public key to it's compressed version

  ## Examples
      iex> Aewallet.Encoding.decode("ae1qq04nuehhr26nz7ggtgaqq939f9hsaq5hrlhsjrlcg5wngpq4pzc968kfa8u")
      {:ok, compressed_pubkey}
  """
  def decode(encoded) do
    {:ok, {_prefix, _version, compressed_pub_key}} = SegwitAddr.decode(encoded)
    {:ok, :binary.list_to_bin(compressed_pub_key)}
  end

end
