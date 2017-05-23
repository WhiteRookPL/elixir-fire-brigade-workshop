defmodule RandomServer do
  use Application

  def start(_type, _args) do
    RandomServer.Supervisor.start_link()
  end
end
