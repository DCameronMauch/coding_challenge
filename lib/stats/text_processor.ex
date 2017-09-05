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
    new_state = state
    |> update_in([:counts, :total], &(&1 + 1))
    |> put_in([:text], text)
    |> put_in([:components], SocialParser.extract(text, [:hashtags, :links]))
    |> update_hashtags
    |> update_domains
    |> update_photos
    |> update_emojis

    {:noreply, new_state}
  end

  def handle_info(:tick, state) do
    CodingChallenge.Stats.CountsAggregator.aggregate({state.sequence, state.counts})
    CodingChallenge.Stats.GenListAggregator.aggregate(:hashtags, {state.sequence, state.hashtags})
    CodingChallenge.Stats.GenListAggregator.aggregate(:domains, {state.sequence, state.domains})
    CodingChallenge.Stats.GenListAggregator.aggregate(:photos, {state.sequence, state.photos})
    CodingChallenge.Stats.GenListAggregator.aggregate(:emojis, {state.sequence, state.emojis})

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
      text: nil,
      components: nil,

      counts: %{
        total: 0,
        hashtags: 0,
        domains: 0,
        photos: 0,
        emojis: 0
      },

      hashtags: %{},
      domains: %{},
      photos: %{},
      emojis: %{}
    }
  end

  defp update_hashtags(state) do
    hashtags = Map.get(state.components, :hashtags, [])
    |> Enum.filter(&String.printable?/1)

    generic_updater(state, :hashtags, hashtags)
  end

  defp update_domains(state) do
    domains = Map.get(state.components, :links, [])
    |> Enum.filter(&String.printable?/1)
    |> Enum.map(&get_domain/1)

    generic_updater(state, :domains, domains)
  end

  defp get_domain(url) do
    URI.parse(url).host
  end

  defp update_photos(state) do
    photos = Map.get(state.components, :links, [])
    |> Enum.filter(&String.printable?/1)
    |> Enum.filter(&is_photo/1)

    generic_updater(state, :photos, photos)
  end

  defp is_photo(url) do
    String.ends_with?(url, [".gif", ".jpg", ".jpeg", ".png", ".tiff", ".bmp"])
  end

  defp update_emojis(state) do
    emojis = Exmoji.Scanner.scan(state.text)
    |> Enum.map(&(&1.short_name))

    generic_updater(state, :emojis, emojis)
  end

  def generic_updater(state, name, objects) do
    if Enum.count(objects) > 0 do
      Enum.reduce(objects, state, fn(object, aggregator) ->
        put_in(aggregator, [name], Helpers.count_map_merger(state[name], %{object => 1}))
      end)
      |> update_in([:counts, name], &(&1 + 1))
    else
      state
    end
  end
end
