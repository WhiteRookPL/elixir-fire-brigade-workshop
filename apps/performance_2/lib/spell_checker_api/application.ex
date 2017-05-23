defmodule SpellCheckerAPI.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(SpellCheckerAPI.Web.Endpoint, [])
    ]

    opts = [ strategy: :one_for_one, name: SpellCheckerAPI.Supervisor ]
    Supervisor.start_link(children, opts)
  end
end