defmodule Crasher.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(Crasher.MemoryEater, [ Crasher.MemoryEater1 ], id: Crasher.MemoryEater1),

      worker(Crasher.AtomEater, [ Crasher.AtomEater1  ], id: Crasher.AtomEater1),
      worker(Crasher.AtomEater, [ Crasher.AtomEater2  ], id: Crasher.AtomEater2),
      worker(Crasher.AtomEater, [ Crasher.AtomEater3  ], id: Crasher.AtomEater3),
      worker(Crasher.AtomEater, [ Crasher.AtomEater4  ], id: Crasher.AtomEater4),
      worker(Crasher.AtomEater, [ Crasher.AtomEater5  ], id: Crasher.AtomEater5),
      worker(Crasher.AtomEater, [ Crasher.AtomEater6  ], id: Crasher.AtomEater6),
      worker(Crasher.AtomEater, [ Crasher.AtomEater7  ], id: Crasher.AtomEater7),
      worker(Crasher.AtomEater, [ Crasher.AtomEater8  ], id: Crasher.AtomEater8),
      worker(Crasher.AtomEater, [ Crasher.AtomEater9  ], id: Crasher.AtomEater9),
      worker(Crasher.AtomEater, [ Crasher.AtomEater10 ], id: Crasher.AtomEater10)
    ]

    supervise(children, strategy: :one_for_one)
  end
end