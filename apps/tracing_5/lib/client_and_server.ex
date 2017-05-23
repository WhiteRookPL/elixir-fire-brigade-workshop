defmodule ClientAndServer do
  use Application

  def start(_type, _args) do
    ClientAndServer.MainSupervisor.start_link()
  end

  def stop_server() do
    Process.exit(Process.whereis(ClientAndServer.Server.SocketsSupervisor), :kill)
  end

  def start_server() do
    import Supervisor.Spec

    Supervisor.start_child(
      ClientAndServer.MainSupervisor,
      supervisor(ClientAndServer.Server.SocketsSupervisor, [], restart: :temporary)
    )
  end
end
