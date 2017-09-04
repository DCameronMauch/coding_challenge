defmodule CodingChallenge.Stats.ListTagAggregator do
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

      domains: %{},
      top_domains: [],

      photos: %{},
      top_photos: [],

      emojis: %{},
      top_emojis: []
    }

    {:ok, state}
  end

  def handle_cast({:aggregate, {sequence, hash_tags, domains, photos, emojis}}, state) do
    new_state = state
    |> update_tops(sequence)
    |> put_in([:hash_tags], Helpers.count_map_merger(state.hash_tags, hash_tags))
    |> put_in([:domains], Helpers.count_map_merger(state.domains, domains))
    |> put_in([:photos], Helpers.count_map_merger(state.photos, photos))
    |> put_in([:emojis], Helpers.count_map_merger(state.emojis, emojis))

    {:noreply, new_state}
  end

  def handle_call(:get_stats, _from, state) do
    stats = %{
      top_hash_tags: state.top_hash_tags,
      top_domains: state.top_domains,
      top_photos: state.top_photos,
      top_emojis: state.top_emojis
    }

    {:reply, stats, state}
  end

  defp update_tops(state, sequence) do
    if sequence == state.sequence do
      state
    else
      top_hash_tags = Helpers.top_10_count_map(state.hash_tags)
      top_domains = Helpers.top_10_count_map(state.domains)
      top_photos = Helpers.top_10_count_map(state.photos)
      top_emojis = Helpers.top_10_count_map(state.emojis)

      state
      |> update_in([:sequence], &(&1 + 1))
      |> put_in([:top_hash_tags], top_hash_tags)
      |> put_in([:top_domains], top_domains)
      |> put_in([:top_photos], top_photos)
      |> put_in([:top_emojis], top_emojis)
    end
  end
end