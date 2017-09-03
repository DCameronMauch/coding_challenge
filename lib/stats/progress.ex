defmodule CodingChallenge.Stats.Progress do
  @moduledoc false

  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def tick do
    GenServer.cast(__MODULE__, :tick)
  end

  def init(:ok) do
    {:ok, 0}
  end

  def handle_cast(:tick, count) do
    new_count = rem(count + 1, 100)

#    if new_count == 0 do
#      IO.write(".")
#    end

    {:noreply, new_count}
  end
end