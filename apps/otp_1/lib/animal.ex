defmodule World.Animal do
  use GenServer

  def start_link(species) do
    GenServer.start_link(__MODULE__, species, [ {:debug, [:log, :trace]} ])
  end

  def init(species) do
    {:ok, %{ :species => species }}
  end

  def handle_call(_message, _from, state) do
    {:stop, :dead, :dead, state}
  end

  def handle_cast(_message, state) do
    {:stop, :dead, state}
  end

  def handle_info(_message, state) do
    {:stop, :dead, state}
  end
end