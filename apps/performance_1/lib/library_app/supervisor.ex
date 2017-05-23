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

    options = [ strategy: :one_for_one, name: __MODULE__ ]
    supervise(children, options)
  end
end