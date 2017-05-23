defmodule MetricsCollector.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(MetricsCollector.Schema.Repo, []),
      supervisor(MetricsCollector.Web.Endpoint, [])
    ]

    opts = [ strategy: :one_for_one, name: MetricsCollector.Supervisor ]
    Supervisor.start_link(children, opts)
  end
end