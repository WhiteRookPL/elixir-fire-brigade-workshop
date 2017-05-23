defmodule Chatterboxes.Statistics do
  use GenServer

  @frequency_in_ms 10_000

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def calculate_statistics(element) do
    GenServer.call(__MODULE__, {:new_element, element})
  end

  def get_result() do
    GenServer.call(__MODULE__, :get_results)
  end

  def init(:ok) do
    jobs = %{}
    refs = %{}
    pending = []

    seed = 1

    Process.send_after(self(), :tick, @frequency_in_ms)

    {:ok, {pending, jobs, refs, seed}}
  end

  def handle_cast({:finished, job_id, type, result}, {pending, jobs, refs, seed}) do
    updated_jobs = Map.update!(jobs, job_id, fn(_) -> {type, result} end)
    updated_refs = Map.new(Enum.reject(refs, &match?({_, ^job_id}, &1)))

    {:noreply, {pending, updated_jobs, updated_refs, seed}}
  end

  def handle_call({:new_element, element}, _from, {pending, jobs, refs, seed}) do
    {:reply, :accepted, {[ element | pending ], jobs, refs, seed}}
  end

  def handle_call(:get_results, _from, {_pending, jobs, _refs, _seed} = state) do
    {:reply, jobs, state}
  end

  def handle_info(:aggregate, {pending, jobs, refs, job_id}) do
    sum_id = job_id
    avg_id = job_id + 1

    {:ok, sum_pid} = Chatterboxes.Statistics.AggregationJob.start(sum_id, :sum, pending)
    {:ok, avg_pid} = Chatterboxes.Statistics.AggregationJob.start(avg_id, :avg, pending)

    sum_ref = Process.monitor(sum_pid)
    avg_ref = Process.monitor(avg_pid)

    updated_refs = Map.merge(refs, %{ sum_id => sum_ref, avg_id => avg_ref })
    updated_jobs = Map.merge(jobs, %{ sum_id => :in_progress, avg_id => :in_progress })

    Process.send_after(self(), :aggregate, @frequency_in_ms)

    {:noreply, {[], updated_jobs, updated_refs, job_id + 2}}
  end

  def handle_info({:DOWN, ref, :process, _pid, reason}, {jobs, refs, seed}) when reason != :normal do
    {job_id, updated_refs} = Map.pop(refs, ref)

    updated_jobs = Map.update!(jobs, job_id, fn(_) -> :failed end)

    {:noreply, {updated_jobs, updated_refs, seed}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end