defmodule PeriodicGenServerApp.Behaviour do
  use GenServer

  @type init_succeeded :: {:ok, state :: term}
  @type init_failed :: {:error, reason :: term}

  @type operation_succeeded :: {:ok, state :: term}
  @type operation_failed :: {:error, reason :: term}

  @type periodic_gen_server_configuration_option :: {:frequency_in_ms, freq :: non_neg_integer} | {:initial_sync, flag :: boolean}
  @type periodic_gen_server_configuration :: list(periodic_gen_server_configuration_option) | []

  @callback init_internal_state(configuration :: periodic_gen_server_configuration) :: init_succeeded | init_failed
  @callback handle_periodic_operation(state :: term) :: operation_succeeded | operation_failed
  @callback handle_query_state(field :: atom, state :: term) :: operation_succeeded | operation_failed

  @default_frequency 5 * 60 * 1000
  @default_initial_sync true

  def start_link(module, configuration) do
    GenServer.start_link(__MODULE__, [module, configuration], name: module)
  end

  def stop(module) do
    GenServer.call(module, :stop)
  end

  def get_state(module, field) do
    GenServer.call(module, {:query_state, field})
  end

  def init([module, configuration]) do
    case module.init_internal_state(configuration) do
      {:ok, additonal_state} ->
        frequency = Keyword.get(configuration, :frequency_in_ms, @default_frequency)
        should_perform_initial_sync = Keyword.get(configuration, :initial_sync, @default_initial_sync)

        update_state = maybe_do_initial_sync(
          should_perform_initial_sync,
          additonal_state,
          fn() -> module.handle_periodic_operation(additonal_state) end
        )

        Process.send_after(self(), :tick, frequency)

        {:ok, {module, frequency, update_state}}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end

  def handle_call({:query_state, field}, _from, {module, _frequency, internal_state} = state) do
    result = case module.handle_query_state(field, internal_state) do
        {:ok, value} -> value
        {:error, _}  -> :undefined
    end

    {:reply, result, state}
  end

  def handle_info(:tick, {module, frequency, internal_state}) do
    new_state = case module.handle_periodic_operation(internal_state) do
        {:ok, changed_state} -> changed_state;
        {:error, _reason}    -> internal_state
    end

    Process.send_after(self(), :tick, frequency)

    {:noreply, {module, frequency, new_state}}
  end

  defp maybe_do_initial_sync(false, previous_state, _), do: previous_state
  defp maybe_do_initial_sync(true, previous_state, function) do
    case function.() do
        {:ok, changed_state} -> changed_state
        {:error, _reason}    -> previous_state
    end
  end
end