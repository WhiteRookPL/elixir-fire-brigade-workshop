defmodule MagicEightBall.Server do
  use GenServer
  require Logger

  # Public API.

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: name)
  end

  def question?(question) do
    GenServer.call(__MODULE__, {:question, question})
  end

  def get_history() do
    GenServer.call(__MODULE__, :get_history)
  end

  # Callbacks implementation.

  def init(_) do
    Logger.debug("MagicEightBall server started and waiting for your questions.")
    {:ok, %{ :history => [] }}
  end

  def handle_call({:question, question}, _from, %{ :history => history }) do
    {result, new_history} = case MagicEightBall.Logic.question(question) do
      {:ok, answer} ->
          {answer, [ {question, answer} | history ]}

      :not_a_question ->
          {"You didn't ask a question!", history}
    end

    {:reply, result, %{ :history => new_history }}
  end

  def handle_call(:get_history, _from, %{ :history => history } = state) do
    {:reply, history, state}
  end
end