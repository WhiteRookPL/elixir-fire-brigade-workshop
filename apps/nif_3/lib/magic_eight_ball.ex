defmodule MagicEightBall do
  use Application

  def start(_type, _args) do
    MagicEightBall.Supervisor.start_link()
  end
end
