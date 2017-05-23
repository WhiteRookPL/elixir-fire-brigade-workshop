use Mix.Config

config :metrics_collector, MetricsCollector.Web.Endpoint,
  http: [
    port: 4000,
    acceptors: 2
  ],
  debug_errors: true,
  code_reloader: true,
  check_origin: false

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :metrics_collector, MetricsCollector.Schema.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "metrics_collector",
  hostname: "localhost",
  pool_size: 2