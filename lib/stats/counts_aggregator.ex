defmodule CodingChallenge.Stats.CountsAggregator do
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

      counts: %{
        total: 0,
        hashtag: 0,
        domain: 0,
        photo: 0,
        emoji: 0
      },

      percents: %{
        hashtag: 0,
        domain: 0,
        photo: 0,
        emoji: 0
      },

      lists: %{
        second: [],
        minute: [],
        hour: [],

      },

      averages: %{
        second: 0,
        minute: 0,
        hour: 0
      }
    }

    {:ok, state}
  end

  def handle_cast({:aggregate, {sequence, counts}}, state) do
    new_state = if sequence == state.sequence do
      incoming_state(state, counts)
    else
      stepped_state(state, counts)
    end

    {:noreply, new_state}
  end

  def handle_call(:get_stats, _from, state) do
    stats = %{
      counts: state.counts,
      percents: state.percents,
      averages: state.averages
    }

    {:reply, stats, state}
  end

  defp incoming_state(state, counts) do
    state
    |> put_in([:lists, :second], [counts.total | state.lists.second])
    |> update_counts(counts)
  end

  defp stepped_state(state, counts) do
    state
    |> update_in([:sequence], &(&1 + 1))
    |> update_percents()
    |> update_lists(counts.total)
    |> update_averages()
    |> update_counts(counts)
  end

  def update_counts(state, counts) do
    state
    |> put_in([:counts], Helpers.count_map_merger(state.counts, counts))
  end

  def update_percents(state) do
    state
    |> put_in([:percents, :hashtag], percent(state.counts.hashtag, state.counts.total))
    |> put_in([:percents, :domain], percent(state.counts.domain, state.counts.total))
    |> put_in([:percents, :photo], percent(state.counts.photo, state.counts.total))
    |> put_in([:percents, :emoji], percent(state.counts.emoji, state.counts.total))
  end

  def update_lists(state, total) do
    second = sum(state.lists.second)
    minute = [second | state.lists.minute] |> Enum.take(60)
    hour = [second | state.lists.hour] |> Enum.take(3600)

    state
    |> put_in([:lists, :second], [total])
    |> put_in([:lists, :minute], minute)
    |> put_in([:lists, :hour], hour)
  end

  def update_averages(state) do
    [second | _tail] = state.lists.minute
    minute = average(state.lists.minute)
    hour = average(state.lists.hour)

    state
    |> put_in([:averages, :second], second)
    |> put_in([:averages, :minute], minute)
    |> put_in([:averages, :hour], hour)
  end

  defp percent(_, 0), do: 0

  defp percent(dividend, divisor) do
    div(100 * dividend, divisor)
  end

  defp sum([]), do: 0

  defp sum(list) do
    Enum.sum(list)
  end

  defp average([]), do: 0

  defp average(list) do
    sum = Enum.sum(list)
    count = Enum.count(list)
    div(sum, count)
  end
end
