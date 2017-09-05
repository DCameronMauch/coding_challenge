defmodule CodingChallenge.Stats.DomainAggregator do
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

      domains: %{},
      top_domains: [],
    }

    {:ok, state}
  end

  def handle_cast({:aggregate, {sequence, domains}}, state) do
    new_state = state
    |> update_top(sequence)
    |> put_in([:domains], Helpers.count_map_merger(state.domains, domains))

    {:noreply, new_state}
  end

  def handle_call(:get_stats, _from, state) do
    stats = %{
      top_domains: state.top_domains
    }

    {:reply, stats, state}
  end

  defp update_top(state, sequence) do
    if sequence == state.sequence do
      state
    else
      top_domains = Helpers.top_10_count_map(state.domains)

      state
      |> update_in([:sequence], &(&1 + 1))
      |> put_in([:top_domains], top_domains)
    end
  end
end
