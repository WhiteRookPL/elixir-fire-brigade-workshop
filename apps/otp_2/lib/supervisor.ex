defmodule Chatterboxes.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(Chatterboxes.Statistics, []),

      worker(Chatterboxes.Blabber, [ Chatterboxes.Blabber1 ], id: Chatterboxes.Blabber1),
      worker(Chatterboxes.Blabber, [ Chatterboxes.Blabber2 ], id: Chatterboxes.Blabber2),
      worker(Chatterboxes.Blabber, [ Chatterboxes.Blabber3 ], id: Chatterboxes.Blabber3),
      worker(Chatterboxes.Blabber, [ Chatterboxes.Blabber4 ], id: Chatterboxes.Blabber4),
      worker(Chatterboxes.Blabber, [ Chatterboxes.Blabber5 ], id: Chatterboxes.Blabber5)
    ]

    supervise(children, strategy: :rest_for_one)
  end
end