defmodule ClientAndServer.MainSupervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      supervisor(ClientAndServer.Server.SocketsSupervisor, [], restart: :temporary),
      supervisor(ClientAndServer.Client.PoolSupervisor, [], restart: :temporary)
    ]

    supervise(children, strategy: :rest_for_one)
  end
end