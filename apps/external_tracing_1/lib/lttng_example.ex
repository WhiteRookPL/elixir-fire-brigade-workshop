defmodule LttngExample do
  use Application

  def start(_type, _args) do
    :code.ensure_loaded(:dyntrace)
    :erlang.trace(:new, true, [:procs, {:tracer, :dyntrace, []}])

    LttngExample.Supervisor.start_link()
  end
end
