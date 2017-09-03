defmodule CodingChallenge.Stats.TextProcessor do
  @moduledoc false
  @step 1000

  alias CodingChallenge.Stats.Helpers

  use GenServer

  def start_link(time) do
    GenServer.start_link(__MODULE__, time, [])
  end

  def init(time) do
    new_time = tick(time)
    state = initial_state(0, new_time)

    {:ok, state}
  end

  def handle_cast({:text, text}, state) do
    hash_tags = hash_tags(text)
    new_state = state
    |> put_in([:count], state.count + 1)
    |> put_in([:hash_tags], Helpers.count_map_merger(state.hash_tags, hash_tags))

    {:noreply, new_state}
  end

  def handle_info(:tick, state) do
    CodingChallenge.Stats.CountAggregator.aggregate({state.sequence, state.count})
    CodingChallenge.Stats.HashTagAggregator.aggregate({state.sequence, state.hash_tags})

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
      count: 0,
      hash_tags: %{}
    }
  end

  @hash_tag_regex ~r/#\w+/u

  defp hash_tags(text) do
    Regex.scan(@hash_tag_regex, String.downcase(text))
    |> Enum.reduce(%{}, fn([hash_tag], accumulator) ->
      Helpers.count_map_merger(accumulator, %{hash_tag => 1})
    end)
  end
end