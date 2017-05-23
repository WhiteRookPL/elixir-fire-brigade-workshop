defmodule RedisClone.Server do
  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port, [ :binary, packet: :line, active: false, reuseaddr: true ])

    table = RedisClone.Storage.initialize(:main_bucket)

    loop_acceptor(socket, table)
  end

  defp loop_acceptor(socket, table) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(RedisClone.Server.TaskSupervisor, fn() -> serve(table, client) end)

    :ok = :gen_tcp.controlling_process(client, pid)

    loop_acceptor(socket, table)
  end

  defp serve(table, socket) do
    msg =
      with {:ok, data} <- read_line(socket),
           {:ok, command} <- RedisClone.Engine.parse_command(data),
           do: RedisClone.Engine.run(table, command)

    write_line(socket, msg)
    serve(table, socket)
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  defp write_line(socket, {:ok, :nothing}) do
    # Known error. Write to the client.
    :gen_tcp.send(socket, ":NOT FOUND:\r\n")
  end

  defp write_line(socket, {:ok, text}) do
    :gen_tcp.send(socket, text)
  end

  defp write_line(socket, {:error, :unknown_command}) do
    # Known error. Write to the client.
    :gen_tcp.send(socket, ":UNKNOWN COMMAND:\r\n")
  end

  defp write_line(_socket, {:error, :closed}) do
    # The connection was closed, exit politely.
    exit(:shutdown)
  end

  defp write_line(socket, {:error, error}) do
    # Unknown error. Write to the client and exit.
    :gen_tcp.send(socket, ":ERROR:\r\n")
    exit(error)
  end
end