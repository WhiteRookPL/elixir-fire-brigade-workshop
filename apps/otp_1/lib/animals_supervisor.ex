defmodule World.Animals.Supervisor do
  use Supervisor

  def start_link(type) do
    Supervisor.start_link(__MODULE__, type, name: type)
  end

  def init(type) do
    children = [
      worker(World.Animal, [type], id: type, restart: :permanent),
    ]

    supervise(children, strategy: :simple_one_for_one, intensity: 5, period: 1)
  end
end