defmodule SentencesAPI.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(SentencesAPI.Web.Endpoint, [])
    ]

    :random.seed(:erlang.now)

    opts = [ strategy: :one_for_one, name: SentencesAPI.Supervisor ]
    Supervisor.start_link(children, opts)
  end
end