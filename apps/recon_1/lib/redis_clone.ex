defmodule RedisClone do
  use Application

  def start(_type, _args) do
    RedisClone.Supervisor.start_link()
  end
end
