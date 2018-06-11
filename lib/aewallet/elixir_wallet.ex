defmodule Aewallet.Wallet do
  @moduledoc """
  This module is used for creation of the Wallet file. To inspect it use
  WalletCrypto.decrypt_wallet("wallet_file_name", "password", "mnemonic_phrase")
  """

  alias Aewallet.KeyPair, as: KeyPair
  alias Aewallet.Cypher, as: Cypher
  alias Aewallet.Mnemonic, as: Mnemonic
  alias Aewallet.Indexes, as: Indexes
  alias Aewallet.Wallet, as: Wallet

  @typedoc "Wallet option key"
  @type wallet_key :: :type

  @typedoc "Wallet option value"
  @type wallet_type :: :ae | :btc

  @typedoc "Wallet options list"
  @type wallet_opts :: [{wallet_key, wallet_type}]

  @typedoc "Network option key"
  @type network_key :: :network

  @typedoc "Network option value"
  @type network_value :: :mainnet | :testnet

  @typedoc "Network options list"
  @type network_opts :: [{network_key, network_value}]

  @secp256k1 "0"

  @curve25519 "1"

  @doc """
  Creates a wallet file. You can use the short function to create an Aeternity wallet
  without using pass_phrase, or use the full function and fill the parameters.

  ## Options

  The accepted options are:

    * `:type` - specifies the type of wallet

  The values for `:type` are:

    * `:ae` - creates an Aeternity wallet
    * `:btc` - creates a Bitcoin wallet

  ## Examples
      iex> Wallet.create_wallet(password, path)
      {:ok, "whisper edit clump violin blame few ancient casual
      sand trip update spring", "home/desktop/wallet/...", :ae}

      iex> Wallet.create_wallet(password, path, pass_phrase, type: :btc)
      {:ok, "whisper edit clump violin blame few ancient casual
      sand trip update spring", "home/desktop/wallet/...", :btc}
  """
  @spec create_wallet(String.t(), String.t()) ::
  {:ok, String.t(), String.t(), wallet_type()} | {:error, String.t()}
  def create_wallet(password, path) do
    create_wallet(password, path, "", [])
  end

  @spec create_wallet(String.t(), String.t(), String.t(), wallet_opts()) ::
  {:ok, String.t(), String.t(), wallet_type()} | {:error, String.t()}
  def create_wallet(password, path, pass_phrase, opts \\ []) do
    mnemonic_phrase = Mnemonic.generate_phrase(Indexes.generate_indexes)
    Wallet.import_wallet(mnemonic_phrase, password, path, pass_phrase, opts)
  end

  @doc """
  Creates a wallet file from an existing mnemonic_phrase and password
  If the wallet was not password protected, just pass the mnemonic_phrase
  """
  @spec import_wallet(String.t(), String.t(), String.t()) ::
  {:ok, String.t(), String.t(), wallet_type()} | {:error, String.t()}
  def import_wallet(mnemonic_phrase, password, path) do
    import_wallet(mnemonic_phrase, password, path, "", [])
  end

  @spec import_wallet(String.t(), String.t(), String.t(), String.t(), wallet_opts()) ::
  {:ok, String.t(), String.t(), wallet_type()} | {:error, String.t()}
  def import_wallet(mnemonic_phrase, password, path, pass_phrase, opts \\ []) do
    type = Keyword.get(opts, :type, :ae)

    {:ok, wallet_data} = build_wallet(mnemonic_phrase, pass_phrase, type)
    {:ok, file_path} = save_wallet_file!(wallet_data, password, path)
    {:ok, mnemonic_phrase, file_path, type}
  end

  @doc """
  Loads the wallet data
    * Mnemonic phrase
    * Wallet type
    * Pass_phrase (if given when wallet was created)

  ## Example
      iex> Aewallet.Wallet.load_wallet_file(file_path, password)
      {:ok,
      "amazing feed doctor wing town furnace need hat public that derive athlete",
      :ae}
  """
  @spec load_wallet_file(String.t(), String.t()) :: tuple()
  def load_wallet_file(file_path, password) do
    load_wallet(File.read(file_path), password)
  end

  @doc """
  Gets the seed of the wallet.

  ## Examples
      iex> Wallet.get_seed(file_path, password)
      {:ok, seed}
  """
  @spec get_seed(String.t(), String.t()) :: {:ok, binary()} | {:error, String.t()}
  def get_seed(file_path, password) do
    case load_wallet_file(file_path, password) do
      {:ok, mnemonic, wallet_type, pass_phrase} ->
        seed =
          mnemonic
          |> KeyPair.generate_seed(pass_phrase)

        {:ok, seed}

      {:error, message} ->
        {:error, message}
    end
  end

  @doc """
  Gets the private key. Will only return a private key if
  the password is correct. Set a desired network with the options
  The default network is `:mainnet`.

  ## Options
  The accepted options are:
    * `:network` - specifies the network

  The values for `:network` can be:
    * `:mainnet` - (default)
    * `:testnet`

  ## Examples
      iex> Wallet.get_private_key(file_path, password)
      {:ok, private_key_for_mainnet}

      iex> Wallet.get_private_key(file_path, password, network: :testnet)
      {:ok, private_key_for_testnet}
  """
  @spec get_private_key(String.t(), String.t(), network_opts()) :: {:ok, binary()} | {:error, String.t()}
  def get_private_key(file_path, password, opts \\ []) do
    network = Keyword.get(opts, :network, :mainnet)

    case load_wallet_file(file_path, password) do
      {:ok, mnemonic, wallet_type, pass_phrase} ->
        private_key =
          mnemonic
          |> KeyPair.generate_seed(pass_phrase)
          |> KeyPair.generate_master_key(network, type: wallet_type)

        {:ok, private_key.key}

      {:ok, pubkey, privkey} ->
        {:ok, privkey}

      {:error, message} ->
        {:error, message}
    end
  end

  @doc """
  Gets the public key. Will only return a public key
  if the password is correct. Set a desired network with the options
  The default network is `:mainnet`.

  ## Options
  The accepted options are:
    * `:network` - specifies the network

  The values for `:network` can be:
    * `:mainnet` - (default)
    * `:testnet`

  ## Examples
      iex> Wallet.get_public_key(file_path, password)
      {:ok, public_key_for_mainnet}

      iex> Wallet.get_public_key(file_path, password, network: :testnet)
      {:ok, public_key_for_testnet}
  """
  @spec get_public_key(String.t(), String.t(), network_opts()) :: {:ok, binary()} | {:error, String.t()}
  def get_public_key(file_path, password, opts \\ []) do
    case load_wallet_file(file_path, password) do
      {:ok, mnemonic, wallet_type, pass_phrase} ->
        case get_private_key(file_path, password, opts) do
          {:ok, private_key} ->
            compressed_pub_key =
              private_key
              |> KeyPair.generate_pub_key()
              |> KeyPair.compress()

            {:ok, compressed_pub_key}

          {:error, reason} ->
            {:error, reason}
        end

      {:ok, pubkey, privkey} ->
        {:ok, pubkey}

      err ->
        err
    end
  end

  @doc """
  Gets the wallet address. Will only return an address if
  the password is correct. Set a desired network with the options
  The default network is `:mainnet`.
  ## Options
  The accepted options are:
    * `:network` - specifies the network

  The values for `:network` can be:
    * `:mainnet` - (default)
    * `:testnet`

  ## Examples
      iex> Wallet.get_address(file_path, password)
      {:ok, "A1M51tw1MixFCe64g6ExhCEXnowEGrQ2DE"}

      iex> Wallet.get_address(file_path, password, network: :tesnet)
      {:ok, "T6d3d2a14FiXGe17g8ExhCBAnfe4GrD2h5"}
  """
  @spec get_address(String.t(), String.t(), network_opts()) :: {:ok, String.t()} | {:error, String.t()}
  def get_address(file_path, password, opts \\ []) do
    network = Keyword.get(opts, :network, :mainnet)

    {:ok, _, wallet_type, _} = Wallet.load_wallet_file(file_path, password)

    case get_public_key(file_path, password) do
      {:ok, pub_key} ->
        address = KeyPair.generate_wallet_address(pub_key, network, wallet_type)
        {:ok, address}

      {:error, message} ->
        {:error, message}
    end
  end

  ## Private functions

  defp build_wallet(_, pass_phrase, :ae) do
    %{public: pubkey, secret: privkey} = KeyPair.generate_keypair()
    enc_pub = Base.encode16(pubkey)
    enc_priv = Base.encode16(privkey)

    data = @curve25519
    |> Kernel.<>(" ")
    |> Kernel.<>(enc_pub)
    |> Kernel.<>(" ")
    |> Kernel.<>(enc_priv)

    {:ok, data}
  end

  defp build_wallet(mnemonic, pass_phrase, :btc) do
    {:ok, @secp256k1
    |> Kernel.<>(" ")
    |> Kernel.<>(mnemonic)
    |> Kernel.<>(" ")
    |> Kernel.<>(Atom.to_string(:btc))
    |> Kernel.<>(" ")
    |> Kernel.<>(pass_phrase)}
  end

  @spec save_wallet_file!(String.t(), String.t(), String.t()) :: tuple()
  defp save_wallet_file!(wallet_data, password, path) do
    {{year, month, day}, {hours, minutes, seconds}} = :calendar.local_time()
    file_name = "wallet--#{year}-#{month}-#{day}-#{hours}-#{minutes}-#{seconds}"

    file_dir =
      case path do
        "" ->
          default_dir = File.cwd! <> "/wallet"
          File.mkdir(default_dir)
          default_dir
        _ ->
          path
      end

    file_path = Path.join(file_dir, file_name)

    case File.open(file_path, [:write]) do
      {:ok, file} ->
        encrypted = Cypher.encrypt(wallet_data, password)
        IO.binwrite(file, encrypted)
        File.close(file)
        {:ok, file_path}

      {:error, message} ->
        throw({:error, "The path you have given has thrown an #{message} error!"})
    end
  end

  @spec load_wallet({:ok | :error, binary()}, String.t()) ::
  {:ok, String.t(), wallet_type(), String.t() | :error, String.t()}
  defp load_wallet({:ok, encrypted_data}, password) do
    wallet_data = Cypher.decrypt(encrypted_data, password)

    if String.valid? wallet_data do
      data_list = String.split(wallet_data)

      case List.first(data_list) do
        @curve25519 ->
          {enc_pub, _} = List.pop_at(data_list, 1)
          pubkey = Base.decode16!(enc_pub)

          {enc_priv, _} = List.pop_at(data_list, 2)
          privkey = Base.decode16!(enc_priv)

          {:ok, pubkey, privkey}

        @secp256k1 ->
          mnemonic =
            data_list
            |> Enum.slice(0..11)
            |> Enum.join(" ")

          wallet_type =
            data_list
            |> Enum.at(12)
            |> String.to_atom()

          case Enum.at(data_list, 13) do
            :nil ->
              {:ok, mnemonic, wallet_type, ""}

            pass_phrase ->
              {:ok, mnemonic, wallet_type, pass_phrase}
          end
      end
    else
      {:error, "Invalid password"}
    end
  end

  defp load_wallet({:error, reason}, _password) do
    case reason do
      :enoent ->
        {:error, "The file does not exist."}

      :eaccess ->
        {:error, "Missing permision for reading the file,
        or for searching one of the parent directories."}

      :eisdir ->
        {:error, "The named file is a directory."}

      :enotdir ->
        {:error, "A component of the file name is not a directory."}

      :enomem ->
        {:error, "There is not enough memory for the contents of the file."}
    end
  end
end
