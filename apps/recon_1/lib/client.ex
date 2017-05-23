defmodule RedisClone.Client do
  def command(string) do
    socket = open(6379)
    send_data(socket, [string,  ?\r, ?\n])
    String.trim(recv(socket))
  end

  # Private API.

  defp open(port) do
    {:ok, socket} = :gen_tcp.connect('127.0.0.1', port, [:binary, active: false])
    socket
  end

  defp send_data(socket, what) do
    :gen_tcp.send(socket, what)
  end

  defp recv(socket) do
    {:ok, message} = :gen_tcp.recv(socket, 0)
    message
  end
end