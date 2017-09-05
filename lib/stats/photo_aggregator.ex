defmodule CodingChallenge.Stats.PhotoAggregator do
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

      photos: %{},
      top_photos: [],
    }

    {:ok, state}
  end

  def handle_cast({:aggregate, {sequence, photos}}, state) do
    new_state = state
    |> update_top(sequence)
    |> put_in([:photos], Helpers.count_map_merger(state.photos, photos))

    {:noreply, new_state}
  end

  def handle_call(:get_stats, _from, state) do
    stats = %{
      top_photos: state.top_photos
    }

    {:reply, stats, state}
  end

  defp update_top(state, sequence) do
    if sequence == state.sequence do
      state
    else
      top_photos = Helpers.top_10_count_map(state.photos)

      state
      |> update_in([:sequence], &(&1 + 1))
      |> put_in([:top_photos], top_photos)
    end
  end
end
