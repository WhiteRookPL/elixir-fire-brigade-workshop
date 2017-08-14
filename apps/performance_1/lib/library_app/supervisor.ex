defmodule LibraryApp.Supervisor do
  use Supervisor

  require Logger

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    import Supervisor.Spec

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, LibraryApp.Router, [], [ port: 8080 ])
    ]

    Logger.info("Application is now listening on port 8080.")

    # Creating our cache. ;)
    :ets.new(LibraryApp.Cache, [:public, :named_table, :set, {:write_concurrency, true}, {:read_concurrency, true}])

    # Warming up the cache. ;)
    LibraryApp.Resolver.get_authors_lazily()
    LibraryApp.Resolver.get_books_lazily()

    options = [ strategy: :one_for_one, name: __MODULE__ ]
    supervise(children, options)
  end
end