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
        hashtags: 0,
        domains: 0,
        photos: 0,
        emojis: 0
      },

      percents: %{
        hashtags: 0,
        domains: 0,
        photos: 0,
        emojis: 0
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
    put_in(state, [:counts], Helpers.count_map_merger(state.counts, counts))
  end

  def update_percents(state) do
    Map.keys(state.percents)
    |> Enum.reduce(state, fn(key, accumulator) ->
      put_in(accumulator, [:percents, key], percent(state.counts[key], state.counts.total))
    end)
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
