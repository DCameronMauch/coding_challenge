defmodule CodingChallenge.Stats.TextProcessor do
  @moduledoc false

  use GenServer

  def start_link(time) do
    GenServer.start_link(__MODULE__, time, [])
  end

  def init(time) do
    new_time = time + 1000
    new_time |> tick()

    state = new_time |> initial_state()

    {:ok, state}
  end

  def handle_cast({:text, _text}, state) do
#    IO.puts("received text: #{text}")

    new_state = %{state | count: state.count + 1}

    {:noreply, new_state}
  end

  def handle_info(:tick, state) do
    IO.puts("received tick: #{state.count}")

    new_time = state.time + 1000
    new_time |> tick()

    new_state = new_time |> initial_state()

    {:noreply, new_state}
  end

  defp tick(time) do
    Process.send_after(self(), :tick, time, abs: true)
  end

  defp initial_state(time) do
    %{
      time: time,
      count: 0
    }
  end
end