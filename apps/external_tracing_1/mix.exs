defmodule LttngExample.Mixfile do
  use Mix.Project

  def project() do
    [
      app: :lttng_example,

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
      mod: {LttngExample, []}
    ]
  end

  defp apps(env) when env == :test, do: []
  defp apps(_), do: [ :sasl, :logger, :lttng ]

  defp deps() do
    [
      {:lttng, git: "git@github.com:psyeugenic/lttng.git", branch: "master", manager: :make},
      {:distillery, "~> 1.0"},
      {:recon, "~> 2.3"}
    ]
  end
end
