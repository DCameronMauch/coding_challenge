defmodule CodingChallenge.Stats.GenListAggregator do
  @moduledoc false

  alias CodingChallenge.Stats.Helpers

  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: pid(name))
  end

  def aggregate(name, data) do
    GenServer.cast(pid(name), {:aggregate, data})
  end

  def get_stats(name) do
    GenServer.call(pid(name), :get_stats)
  end

  def init(name) do
    state = %{
      name: name,
      sequence: 0,

      objects: %{},
      top_objects: [],
    }

    {:ok, state}
  end

  def pid(name) do
    :"#{name}_aggregator"
  end

  def handle_cast({:aggregate, {sequence, objects}}, state) do
    new_state = state
    |> update_top(sequence)
    |> put_in([:objects], Helpers.count_map_merger(state.objects, objects))

    {:noreply, new_state}
  end

  def handle_call(:get_stats, _from, state) do
    stats = %{
      :"top_#{state.name}" => state.top_objects
    }

    {:reply, stats, state}
  end

  defp update_top(state, sequence) do
    if sequence == state.sequence do
      state
    else
      top_objects = Helpers.top_10_count_map(state.objects)

      state
      |> update_in([:sequence], &(&1 + 1))
      |> put_in([:top_objects], top_objects)
    end
  end
end
