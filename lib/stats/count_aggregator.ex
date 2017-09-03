defmodule CodingChallenge.Stats.CountAggregator do
  @moduledoc false

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
      total: 0,

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

  def handle_cast({:aggregate, {sequence, count}}, state) do
    new_state = if sequence == state.sequence do
      incoming_state(state, count)
    else
      stepped_state(state, count)
    end

    {:noreply, new_state}
  end

  def handle_call(:get_stats, _from, state) do
    stats = %{
      total: state.total,
      averages: state.averages
    }

    {:reply, stats, state}
  end

  defp incoming_state(state, count) do
    state
    |> put_in([:total], state.total + count)
    |> put_in([:lists, :second], [count | state.lists.second])
  end

  defp stepped_state(state, count) do
    new_averages_second = Enum.sum(state.lists.second)

    new_lists_minute = [new_averages_second | state.lists.minute] |> Enum.take(60)
    new_lists_hour = [new_averages_second | state.lists.hour] |> Enum.take(3600)

    new_averages_minute = average(new_lists_minute)
    new_averages_hour = average(new_lists_hour)

    state
    |> put_in([:sequence], state.sequence + 1)
    |> put_in([:total], state.total + count)
    |> put_in([:lists, :second], [count])
    |> put_in([:lists, :minute], new_lists_minute)
    |> put_in([:lists, :hour], new_lists_hour)
    |> put_in([:averages, :second], new_averages_second)
    |> put_in([:averages, :minute], new_averages_minute)
    |> put_in([:averages, :hour], new_averages_hour)
  end

  defp average([]), do: 0

  defp average(list) do
    sum = Enum.sum(list)
    count = Enum.count(list)
    div(sum, count)
  end
end