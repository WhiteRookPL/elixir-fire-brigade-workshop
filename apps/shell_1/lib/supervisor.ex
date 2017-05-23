defmodule TreasureHunt.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(TreasureHunt.Chest, [], restart: :temporary)
    ]

    supervise(children, strategy: :one_for_one, max_restarts: 1, max_seconds: 3600)
  end
end