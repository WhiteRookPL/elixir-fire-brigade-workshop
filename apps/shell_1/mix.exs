defmodule TreasureHunt.Mixfile do
  use Mix.Project

  def project() do
    [
      app: :treasure_hunt,

      version: "1.0.0",
      elixir: "~> 1.4",

      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,

      compilers: [ :elixir_make ] ++ Mix.compilers,

      make_clean: [ "clean" ],
      make_env: %{"MIX_ENV" => to_string(Mix.env)},

      deps: deps()
   ]
  end

  def application() do
    [
      applications: apps(Mix.env),
      mod: {TreasureHunt, []}
    ]
  end

  defp apps(env) when env == :test, do: []
  defp apps(_), do: [ :logger ]

  defp deps() do
    [
      {:elixir_make, "~> 0.4", runtime: false},
      {:distillery, "~> 1.0"},
      {:recon, "~> 2.3"}
    ]
  end
end