defmodule ClientAndServer.Server.SocketsSupervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_socket() do
    Supervisor.start_child(__MODULE__, [])
  end

  def init(:ok) do
    port = Application.get_env(:client_and_server, :port)
    {:ok, listen_socket} = :gen_tcp.listen(port, [packet: :line, active: :once, reuseaddr: true])

    children = [
      worker(ClientAndServer.Server.SocketAcceptor, [ listen_socket ])
    ]

    # Initializing acceptors pool.
    spawn_link(fn() -> for _ <- 1 .. 5, do: start_socket() end)

    supervise(children, strategy: :simple_one_for_one)
  end
end