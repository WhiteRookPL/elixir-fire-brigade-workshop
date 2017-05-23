defmodule RedisClone.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      supervisor(Task.Supervisor, [ [ name: RedisClone.Server.TaskSupervisor ] ]),
      worker(Task, [ RedisClone.Server, :accept, [ 6379 ] ])
    ]

    opts = [ strategy: :rest_for_one, name: RedisClone.Server.Supervisor ]
    supervise(children, opts)
  end
end