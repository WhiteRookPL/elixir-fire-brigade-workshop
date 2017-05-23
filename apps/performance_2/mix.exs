defmodule SpellCheckerAPI.Mixfile do
  use Mix.Project

  def project() do
    [
      app: :spell_checker_api,
      version: "1.0.0",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application() do
    [
      mod: {SpellCheckerAPI.Application, []},
      extra_applications: [ :sasl, :logger, :runtime_tools ]
    ]
  end

  defp elixirc_paths(:test), do: [ "lib", "test/support" ]
  defp elixirc_paths(_),     do: [ "lib" ]

  defp deps() do
    [
      {:phoenix, "~> 1.3"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
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
