defmodule CodingChallenge.Stats.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(CodingChallenge.Stats.Progress, []),
      worker(CodingChallenge.Stats.TwitterReceiver, [])
    ]

    supervise(children, strategy: :rest_for_one)
  end
end