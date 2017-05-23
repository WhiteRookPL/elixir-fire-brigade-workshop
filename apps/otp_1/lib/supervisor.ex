defmodule World.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      supervisor(World.Animals.Supervisor, [World.Dodos.Supervisor], id: World.Dodos.Supervisor, restart: :transient),
      supervisor(World.Animals.Supervisor, [World.Cockroaches.Supervisor], id: World.Cockroaches.Supervisor, restart: :permanent)
    ]

    supervise(children, strategy: :one_for_one, intensity: 100, period: 1)
  end
end