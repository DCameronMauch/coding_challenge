defmodule CodingChallenge.Stats.TwitterReceiver do
  @moduledoc false

  use Task, restart: :permanent

  def start_link do
    Task.start_link(__MODULE__, :runner, [])
  end

  def runner do
    Process.register(self(), __MODULE__)
    IO.puts("twitter receiver running")
    looper()
  end

  defp looper do
    receive do
      msg ->
        IO.puts("received:")
        msg |> IO.inspect()
    end
    looper()
  end
end