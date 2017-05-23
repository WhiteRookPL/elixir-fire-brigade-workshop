defmodule PeriodicGenServerApp.Printer do
  @behaviour PeriodicGenServerApp.Behaviour

  require Logger

  def start_link() do
    PeriodicGenServerApp.Behaviour.start_link(__MODULE__, [frequency_in_ms: 5000, initial_sync: false])
  end

  def count() do
    PeriodicGenServerApp.Behaviour.get_state(__MODULE__, :count)
  end

  def init_internal_state(_) do
    {:ok, 1}
  end

  def handle_periodic_operation(n) do
    Logger.info("Printer ##{n} - Process printed message.")
    {:ok, n + 1}
  end

  def handle_query_state(:count, n) do
    {:ok, n}
  end
end