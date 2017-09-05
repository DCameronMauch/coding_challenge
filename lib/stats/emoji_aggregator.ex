defmodule CodingChallenge.Stats.EmojiAggregator do
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

      emojis: %{},
      top_emojis: []
    }

    {:ok, state}
  end

  def handle_cast({:aggregate, {sequence, emojis}}, state) do
    new_state = state
    |> update_top(sequence)
    |> put_in([:emojis], Helpers.count_map_merger(state.emojis, emojis))

    {:noreply, new_state}
  end

  def handle_call(:get_stats, _from, state) do
    stats = %{
      top_emojis: state.top_emojis
    }

    {:reply, stats, state}
  end

  defp update_top(state, sequence) do
    if sequence == state.sequence do
      state
    else
      top_emojis = Helpers.top_10_count_map(state.emojis)

      state
      |> update_in([:sequence], &(&1 + 1))
      |> put_in([:top_emojis], top_emojis)
    end
  end
end
