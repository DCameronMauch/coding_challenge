defmodule CodingChallenge.Stats.TextProcessor do
  @moduledoc false

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_cast({:text, text}, state) do
    IO.puts("received text: #{text}")
    {:noreply, state}
  end
end