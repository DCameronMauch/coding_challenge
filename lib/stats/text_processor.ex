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
    |> update_hashtags(text)
    |> update_domains_photos(text)
    |> update_emojis(text)

    {:noreply, new_state}
  end

  def handle_info(:tick, state) do
    CodingChallenge.Stats.CountAggregator.aggregate({state.sequence, state.counts})
    CodingChallenge.Stats.HashtagAggregator.aggregate({state.sequence, state.hashtags})
    CodingChallenge.Stats.DomainAggregator.aggregate({state.sequence, state.domains})
    CodingChallenge.Stats.PhotoAggregator.aggregate({state.sequence, state.photos})
    CodingChallenge.Stats.EmojiAggregator.aggregate({state.sequence, state.emojis})

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

      counts: %{
        total: 0,
        hashtag: 0,
        domain: 0,
        photo: 0,
        emoji: 0
      },

      hashtags: %{},
      domains: %{},
      photos: %{},
      emojis: %{}
    }
  end

  @hashtag_regex ~r/\s+#[\w-]+/u

  defp update_hashtags(state, text) do
    hashtags = get_hashtags(text)

    if Enum.count(hashtags) > 0 do
      state
      |> update_in([:counts, :hashtag], &(&1 + 1))
      |> put_in([:hashtags], Helpers.count_map_merger(state.hashtags, hashtags))
    else
      state
    end
  end

  defp get_hashtags(text) do
    Regex.scan(@hashtag_regex, " " <> String.downcase(text))
    |> Enum.reduce(%{}, fn([hashtag], accumulator) ->
      Helpers.count_map_merger(accumulator, %{String.trim_leading(hashtag) => 1})
    end)
  end

  defp update_domains_photos(state, text) do
    domain = get_domain(text)
    photo = get_photo(domain)

    state
    |> update_domains(domain)
    |> update_photos(photo)
  end

  @domain_regex ~r/\s+https?:\/\/[\w\.-]+/u

  defp get_domain(text) do
    case Regex.run(@domain_regex, " " <> String.downcase(text)) do
      nil -> nil
      [url] -> String.trim_leading(url)
    end
    |> case do
         nil -> nil
         "http://" <> domain -> domain
         "https://" <> domain -> domain
    end
  end

  @twitter "pic.twitter.com"
  @instagram "instagram"

  defp get_photo(nil), do: nil

  defp get_photo(domain) do
    if String.contains?(domain, [@twitter, @instagram]) do
      domain
    else
      nil
    end
  end

  defp update_domains(state, nil), do: state

  defp update_domains(state, domain) do
    state
    |> update_in([:counts, :domain], &(&1 + 1))
    |> put_in([:domains], Helpers.count_map_merger(state.domains, %{domain => 1}))
  end

  defp update_photos(state, nil), do: state

  defp update_photos(state, photo) do
    state
    |> update_in([:counts, :photo], &(&1 + 1))
    |> put_in([:photos], Helpers.count_map_merger(state.photos, %{photo => 1}))
  end

  defp update_emojis(state, text) do
    emojis = Exmoji.Scanner.scan(text)
    |> Enum.reduce(%{}, fn(emoji, accumulator) ->
      Helpers.count_map_merger(accumulator, %{emoji.short_name => 1})
    end)

    if Enum.count(emojis) > 0 do
      state
      |> update_in([:counts, :emoji], &(&1 + 1))
      |> put_in([:emojis], Helpers.count_map_merger(state.emojis, emojis))
    else
      state
    end
  end
end
