defmodule SentencesAPI.Mixfile do
  use Mix.Project

  def project() do
    [
      app: :sentences_api,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [ :phoenix, :gettext ] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application() do
    [
      mod: {SentencesAPI.Application, []},
      extra_applications: apps(Mix.env) ++ [ :lager, :logger, :runtime_tools, :wobserver ]
    ]
  end

  defp apps(:test), do: []
  defp apps(_), do: [ :sasl ]

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps() do
    [
      {:phoenix, "~> 1.3.0-rc"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.6"},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:wobserver, "~> 0.1"},
      {:distillery, "~> 1.0"},
      {:xprof, "~> 1.2"},
      {:eper, "~> 0.94"},
      {:dbg, "~> 1.0"},
      {:recon, "~> 2.3"}
    ]
  end
end
