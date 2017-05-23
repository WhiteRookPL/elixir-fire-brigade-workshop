use Mix.Config

config :metrics_collector,
  namespace: MetricsCollector,
  ecto_repos: [
    MetricsCollector.Schema.Repo
    ],
  generators: [
    binary_id: true
  ]

config :metrics_collector, MetricsCollector.Web.Endpoint,
  url: [
    host: "localhost"
  ],
  secret_key_base: "YnfoUuOdMpSK5gZEXWvwDXPw/9whSyUiNvW6mnDhrU2pUL7mVLCm+XXsLPVRfxWo",
  render_errors: [
    view: MetricsCollector.Web.ErrorView,
    accepts: ~w(json)
  ],
  pubsub: [ name: MetricsCollector.PubSub, adapter: Phoenix.PubSub.PG2 ]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

import_config "#{Mix.env}.exs"