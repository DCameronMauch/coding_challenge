defmodule CodingChallenge.Stats.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
    :poolboy.child_spec(:text_processor_pool, poolboy_config()),
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