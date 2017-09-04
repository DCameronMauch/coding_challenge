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
    |> update_hash_tags(text)
    |> update_domains_photos(text)
    |> update_emojis(text)

    {:noreply, new_state}
  end

  def handle_info(:tick, state) do
    CodingChallenge.Stats.CountAggregator.aggregate({state.sequence, state.counts})
    CodingChallenge.Stats.ListTagAggregator.aggregate({state.sequence, state.hash_tags, state.domains, state.photos, state.emojis})

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
        hash_tag: 0,
        domain: 0,
        photo: 0,
        emoji: 0
      },

      hash_tags: %{},
      domains: %{},
      photos: %{},
      emojis: %{}
    }
  end

  @hash_tag_regex ~r/\s+#[\w-]+/u

  defp update_hash_tags(state, text) do
    hash_tags = get_hash_tags(text)

    if Enum.count(hash_tags) > 0 do
      state
      |> update_in([:counts, :hash_tag], &(&1 + 1))
      |> put_in([:hash_tags], Helpers.count_map_merger(state.hash_tags, hash_tags))
    else
      state
    end
  end

  defp get_hash_tags(text) do
    Regex.scan(@hash_tag_regex, " " <> String.downcase(text))
    |> Enum.reduce(%{}, fn([hash_tag], accumulator) ->
      Helpers.count_map_merger(accumulator, %{String.trim_leading(hash_tag) => 1})
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

  defp update_emojis(state, _text) do
    state
  end
end