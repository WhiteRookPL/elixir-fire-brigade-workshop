defmodule World.Mixfile do
  use Mix.Project

  def project() do
    [
      app: :world,

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
      mod: {World, []}
    ]
  end

  defp apps(env) when env == :test, do: [ :runtime_tools ]
  defp apps(_), do: [ :runtime_tools, :lager, :logger, :sasl ]

  defp deps() do
    [
      {:distillery, "~> 1.0"},
      {:xprof, "~> 1.2"},
      {:eper, "~> 0.94"},
      {:dbg, "~> 1.0"},
      {:recon, "~> 2.3"}
    ]
  end
end
