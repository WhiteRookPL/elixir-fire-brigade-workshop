use Mix.Config

config :metrics_collector, MetricsCollector.Web.Endpoint,
  http: [
    port: 4001
  ],
  server: false

config :logger, level: :warn

config :metrics_collector, MetricsCollector.Schema.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "metrics_collector",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox