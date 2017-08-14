defmodule SpellCheckerAPI.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(SpellCheckerAPI.Web.Endpoint, [])
    ]

    :ets.new(SpellCheckerAPI.Cache, [:public, :set, :named_table, {:read_concurrency, true}])
    cache_words()

    opts = [ strategy: :one_for_one, name: SpellCheckerAPI.Supervisor ]
    Supervisor.start_link(children, opts)
  end

  defp cache_words() do
    {:ok, content} = File.read(priv("pl.dict"))

    words =
      content
      |> String.splitter("\n")
      |> Enum.to_list()

    :ets.insert(SpellCheckerAPI.Cache, {:words, words})
  end

  defp priv(filename) do
    Path.join(:code.priv_dir(:spell_checker_api), filename)
  end
end