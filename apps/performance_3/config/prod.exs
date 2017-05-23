use Mix.Config

config :metrics_collector, MetricsCollector.Web.Endpoint,
  on_init: {MetricsCollector.Web.Endpoint, :load_from_system_env, []},
  url: [
    host: "example.com",
    port: 80
  ]

config :logger, level: :info

import_config "prod.secret.exs"