defmodule CurrencyConverter.Mixfile do
  use Mix.Project

  def project() do
    [
      app: :currency_converter,

      version: "1.0.0",
      elixir: "~> 1.4",

      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,

      deps: deps()
   ]
  end

  def application() do
    [
      applications: apps(Mix.env),
      mod: {CurrencyConverter, []}
    ]
  end

  defp apps(env) when env == :test, do: [ :tesla, :ibrowse ]
  defp apps(_), do: [ :lager, :logger, :tesla, :ibrowse ]

  defp deps() do
    [
      {:tesla, "~> 0.7.1"},
      {:poison, "~> 1.0.0"},
      {:ibrowse, "~> 4.2"},
      {:distillery, "~> 1.0"},
      {:xprof, "~> 1.2"},
      {:eper, "~> 0.94"},
      {:dbg, "~> 1.0"},
      {:recon, "~> 2.3"}
    ]
  end
end
