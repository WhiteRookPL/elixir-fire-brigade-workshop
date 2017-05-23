defmodule World do
  use Application

  def start() do
    Application.ensure_all_started(:world)
  end

  def stop() do
    Application.stop(:world)
  end

  def start(_type, _args) do
    World.Supervisor.start_link()
  end

  def stop(_State) do
    :ok
  end

  def add_dodos(n) do
    add_animals(n, World.Dodos.Supervisor)
  end

  def add_cockroaches(n) do
    add_animals(n, World.Cockroaches.Supervisor)
  end

  def dodos() do
    all(World.Dodos.Supervisor)
  end

  def cockroaches() do
    all(World.Cockroaches.Supervisor)
  end

  def kill_dodos() do
    kill_all(dodos())
  end

  def kill_cockroaches() do
    kill_all(cockroaches())
  end

  defp add_animals(0, _), do: :ok
  defp add_animals(n, supervisor) do
    Supervisor.start_child(supervisor, [])
    add_animals(n - 1, supervisor)
  end

  defp all(supervisor) do
    for {_, animal, _ , _} <- Supervisor.which_children(supervisor), into: [], do: animal
  end

  defp kill_all(animals) do
    for animal <- animals, do: Process.exit(animal, :kill)
  end
end
