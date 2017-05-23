defmodule PeriodicGenServerApp.Interrogator do
  @behaviour PeriodicGenServerApp.Behaviour

  require Logger

  def start_link() do
    PeriodicGenServerApp.Behaviour.start_link(__MODULE__, [frequency_in_ms: 2000, initial_sync: true])
  end

  def init_internal_state(_) do
    {:ok, 1}
  end

  def handle_periodic_operation(n) do
    state = PeriodicGenServerApp.Printer.count()

    Logger.info("Interrogator ##{n} - Getting state of `Printer` - Count: #{state}")

    {:ok, n + 1}
  end

  def handle_query_state(:count, n) do
    {:ok, n}
  end
end