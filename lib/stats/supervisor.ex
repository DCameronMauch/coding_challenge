defmodule CodingChallenge.Stats.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    time = System.monotonic_time(:millisecond)

    children = [
      worker(CodingChallenge.Stats.CountsAggregator, []),
      worker(CodingChallenge.Stats.GenListAggregator, [:hashtags], id: :hashtags_aggregator),
      worker(CodingChallenge.Stats.GenListAggregator, [:domains], id: :domains_aggregator),
      worker(CodingChallenge.Stats.GenListAggregator, [:photos], id: :photos_aggregator),
      worker(CodingChallenge.Stats.GenListAggregator, [:emojis], id: :emojis_aggregator),
      :poolboy.child_spec(:text_processor_pool, poolboy_config(), time),
      worker(CodingChallenge.Stats.Progress, []),
      worker(CodingChallenge.Stats.TwitterReceiver, [])
    ]

    supervise(children, strategy: :rest_for_one)
  end

  defp poolboy_config do
    [
      {:name, {:local, :text_processor_pool}},
      {:worker_module, CodingChallenge.Stats.TextProcessor},
      {:size, 8},
      {:max_overflow, 0},
      {:strategy, :fifo}
    ]
  end
end
