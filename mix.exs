defmodule Aewallet.Mixfile do
  use Mix.Project

  def project do
    [
      app: :aewallet,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:base58check, github: "quanterall/base58check"},
      {:seed_generator, github: "quanterall/seed_generator"},
      {:libsecp256k1, [github: "mbrix/libsecp256k1", manager: :rebar]},
      {:excoveralls, "~> 0.7", only: :test},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:bip0173, "~> 0.1.2"},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:enacl, github: "aeternity/enacl", ref: "2f50ba6", override: true}
    ]
  end
end
