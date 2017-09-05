defmodule CodingChallenge.Stats.HashtagAggregator do
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

      hashtags: %{},
      top_hashtags: [],
    }

    {:ok, state}
  end

  def handle_cast({:aggregate, {sequence, hashtags}}, state) do
    new_state = state
    |> update_top(sequence)
    |> put_in([:hashtags], Helpers.count_map_merger(state.hashtags, hashtags))

    {:noreply, new_state}
  end

  def handle_call(:get_stats, _from, state) do
    stats = %{
      top_hashtags: state.top_hashtags
    }

    {:reply, stats, state}
  end

  defp update_top(state, sequence) do
    if sequence == state.sequence do
      state
    else
      top_hashtags = Helpers.top_10_count_map(state.hashtags)

      state
      |> update_in([:sequence], &(&1 + 1))
      |> put_in([:top_hashtags], top_hashtags)
    end
  end
end
