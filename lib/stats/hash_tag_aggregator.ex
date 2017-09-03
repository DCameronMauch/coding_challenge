defmodule CodingChallenge.Stats.HashTagAggregator do
  @moduledoc false

  alias CodingChallenge.Stats.Helpers

  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def aggregate(data) do
    GenServer.cast(__MODULE__, {:aggregate, data})
  end

  def get_stats do
    GenServer.call(__MODULE__, :get_stats)
  end

  def init(:ok) do
    state = %{
      sequence: 0,
      hash_tags: %{},
      top_hash_tags: [],
    }

    {:ok, state}
  end

  def handle_cast({:aggregate, {sequence, hash_tags}}, state) do
    new_state = state
    |> put_in([:hash_tags], Helpers.count_map_merger(state.hash_tags, hash_tags))
    |> top_hash_tags(sequence)

    {:noreply, new_state}
  end

  def handle_call(:get_stats, _from, state) do
    stats = %{
      top_hash_tags: state.top_hash_tags
    }

    {:reply, stats, state}
  end

  defp top_hash_tags(state, sequence) do
    if sequence == state.sequence do
      state
    else
      top_hash_tags = Helpers.top_10_count_map(state.hash_tags)

      state
      |> put_in([:sequence], state.sequence + 1)
      |> put_in([:top_hash_tags], top_hash_tags)
    end
  end
end