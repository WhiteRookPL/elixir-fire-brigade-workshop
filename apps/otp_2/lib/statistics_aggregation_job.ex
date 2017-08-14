defmodule Chatterboxes.Statistics.AggregationJob do
  require Logger

  defmodule State do
    defstruct id: 0, type: nil, elements: nil, result: [], start_time: 0
  end

  def start(id, type, elements, process_options \\ []) do
    state = %State{
      id: id,
      type: type,
      elements: elements,
      start_time: System.system_time()
    }

    :proc_lib.start(__MODULE__, :init, [ self(), state, process_options ])
  end

  # Required functions for `:proc_lib`.

  def system_continue(parent, opts, state) do
    loop(parent, opts, state)
  end

  def system_terminate(reason, _parent, _opts, _state) do
    exit(reason)
  end

  def system_get_state(state) do
    {:ok, state}
  end

  defp write_debug(device, event, name) do
    :io.format(device, "~p event = ~p~n", [ name, event ])
  end

  def system_replace_state(modify_state_fun, state) do
    updated_state = modify_state_fun.(state)
    {:ok, updated_state, updated_state}
  end

  def system_code_change(state, _module, _old_version, _extra) do
    {:ok, state}
  end

  def init(parent, state, process_options) do
    opts = :sys.debug_options(process_options)

    :proc_lib.init_ack(parent, {:ok, self()})

    send(self(), :aggregation)
    loop(parent, opts, state)
  end

  # Private functions.

  defp loop(parent, opts, %State{id: id, type: type, elements: elements, result: result, start_time: start_time} = state) do
    receive do
      :aggregation ->
        new_opts = :sys.handle_debug(opts, &write_debug/3, __MODULE__, {:in, :aggregate})

        send(self(), :final_aggregation_step)
        aggregate = aggregation(elements)

        loop(parent, new_opts, %{state | result: aggregate})

      :final_aggregation_step ->
        new_opts = :sys.handle_debug(opts, &write_debug/3, __MODULE__, {:in, :final_aggregation_step})

        send(self(), :return_result)
        final_aggregate = final_aggregation_step(type, result)

        loop(parent, new_opts, %{state | result: final_aggregate})

      :return_result ->
        :sys.handle_debug(opts, &write_debug/3, __MODULE__, {:in, :return_result})

        GenServer.cast(parent, {:finished, id, type, result})

        end_time = System.system_time()
        Logger.info("Job #{id} took #{System.convert_time_unit(end_time - start_time, :native, :milliseconds)} ms")

      {:system, from, request} ->
        :sys.handle_system_msg(request, from, parent, __MODULE__, opts, state)
        loop(parent, opts, state)
    end
  end

  defp aggregation(elements) do
    sum = Enum.reduce(elements, 0, fn(element, accumulator) ->
      accumulator + element
    end)

    {length(elements), sum}
  end

  defp final_aggregation_step(:avg, {size, sum}) do
    sum / size
  end

  defp final_aggregation_step(:sum, {_size, sum}) do
    sum
  end
end