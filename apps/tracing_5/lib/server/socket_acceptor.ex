defmodule ClientAndServer.Server.SocketAcceptor do
  use GenServer

  def start_link(listen_socket) do
    GenServer.start_link(__MODULE__, listen_socket)
  end

  def init(listen_socket) do
    GenServer.cast(self(), :accept)
    {:ok, listen_socket}
  end

  def handle_cast(:accept, listen_socket) do
    {:ok, accepted_socket} = :gen_tcp.accept(listen_socket)

    ClientAndServer.Server.SocketsSupervisor.start_socket()
    {:noreply, accepted_socket}
  end

  def handle_info({:tcp, _port, message}, socket) do
    :ok = :gen_tcp.send(socket, message)
    :ok = :inet.setopts(socket, [ {:active, :once} ])

    {:noreply, socket}
  end
end