defmodule CodingChallengeWeb.StatsController do
  @moduledoc false
  
  use CodingChallengeWeb, :controller

  def stats(conn, _params) do
    stats = [
      CodingChallenge.Stats.CountAggregator,
      CodingChallenge.Stats.HashTagAggregator
    ]
    |> Enum.reduce(%{}, fn(aggregator, accumulator) ->
      Map.merge(accumulator, aggregator.get_stats)
    end)

    render conn, "stats.json", stats: stats
  end
end