defmodule CodingChallenge.Stats.TextProcessor do
  @moduledoc false

  use GenServer

  def start_link(time) do
    GenServer.start_link(__MODULE__, time, [])
  end

  def init(time) do
    new_time = time + 1000
    new_time |> tick()

    state = %{time: new_time}

    {:ok, state}
  end

  def handle_cast({:text, _text}, state) do
#    IO.puts("received text: #{text}")

    {:noreply, state}
  end

  def handle_info(:tick, state) do
    IO.puts("received tick")

    new_time = state.time + 1000
    new_state = %{state | time: new_time}
    new_time |> tick()

    {:noreply, new_state}
  end

  defp tick(time) do
    Process.send_after(self(), :tick, time, abs: true)
  end
end