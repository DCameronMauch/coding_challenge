defmodule CodingChallenge.Stats.TwitterReceiver do
  @moduledoc false
  


  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    send(self(), :run)
    {:ok, :ok}
  end

  def handle_info(:run, :ok) do
    IO.puts("twitter receiver running")
    {:noreply, :ok}
  end
end