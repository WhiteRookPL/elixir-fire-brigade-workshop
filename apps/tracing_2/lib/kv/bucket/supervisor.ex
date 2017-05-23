defmodule KV.Bucket.Supervisor do
  use Supervisor

  # A simple module attribute that stores the supervisor name
  @name KV.Bucket.Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def start_bucket() do
    Supervisor.start_child(@name, [])
  end

  def init(:ok) do
    children = [
      worker(KV.Bucket, [], restart: :permanent)
    ]

    supervise(children, strategy: :simple_one_for_one, max_restarts: 10, max_seconds: 1)
  end
end