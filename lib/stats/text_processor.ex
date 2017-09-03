defmodule CodingChallenge.Stats.TextProcessor do
  @moduledoc false
  @step 1000

  use GenServer

  def start_link(time) do
    GenServer.start_link(__MODULE__, time, [])
  end

  def init(time) do
    new_time = tick(time)
    state = initial_state(0, new_time)

    {:ok, state}
  end

  def handle_cast({:text, _text}, state) do
    new_state = %{state | count: state.count + 1}

    {:noreply, new_state}
  end

  def handle_info(:tick, state) do
    CodingChallenge.Stats.CountAggregator.aggregate({state.sequence, state.count})

    new_time = tick(state.time)
    new_state = initial_state(state.sequence + 1, new_time)

    {:noreply, new_state}
  end

  defp tick(time) do
    new_time = time + @step
    Process.send_after(self(), :tick, new_time, abs: true)
    new_time
  end

  defp initial_state(sequence, time) do
    %{
      sequence: sequence,
      time: time,
      count: 0
    }
  end
end