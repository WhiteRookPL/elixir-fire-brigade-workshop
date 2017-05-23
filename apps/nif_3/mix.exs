defmodule MagicEightBall.Mixfile do
  use Mix.Project

  def project() do
    [
      app: :magic_eight_ball,

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
      mod: {MagicEightBall, []}
    ]
  end

  defp apps(_), do: [ :lager, :logger ]

  defp deps() do
    [
      {:elixir_make, "~> 0.4", runtime: false},
      {:distillery, "~> 1.0"},
      {:xprof, "~> 1.2"},
      {:eper, "~> 0.94"},
      {:dbg, "~> 1.0"},
      {:recon, "~> 2.3"}
    ]
  end
end
