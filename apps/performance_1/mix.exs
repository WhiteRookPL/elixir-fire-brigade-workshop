defmodule LibraryApp.Mixfile do
  use Mix.Project

  def project() do
    [
      app: :library_app,

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
      mod: {LibraryApp, []}
    ]
  end

  @default_apps [ :cowboy, :plug, :absinthe_plug ]

  defp apps(env) when env == :test, do: @default_apps
  defp apps(_), do: [ :lager, :logger ] ++ @default_apps

  defp deps() do
    [
      {:cowboy, "~> 1.1"},
      {:plug, "~> 1.4.0"},

      {:absinthe, "~> 1.4.0-beta.2" },
      {:absinthe_plug, "~> 1.4.0-beta.1"},

      {:poison, "~> 2.1"},

      {:distillery, "~> 1.0"},
      {:xprof, "~> 1.2"},
      {:eper, "~> 0.94"},
      {:dbg, "~> 1.0"},
      {:recon, "~> 2.3"}
    ]
  end
end
