defmodule CodingChallengeWeb.StatsController do
  @moduledoc false

  use CodingChallengeWeb, :controller

  def stats(conn, _params) do
    stats = [
      {CodingChallenge.Stats.CountsAggregator, []},
      {CodingChallenge.Stats.GenListAggregator, [:hashtags]},
      {CodingChallenge.Stats.GenListAggregator, [:domains]},
      {CodingChallenge.Stats.GenListAggregator, [:photos]},
      {CodingChallenge.Stats.GenListAggregator, [:emojis]}
    ]
    |> Enum.reduce(%{}, fn({aggregator, args}, accumulator) ->
      Map.merge(accumulator, apply(aggregator, :get_stats, args))
    end)

    render conn, "stats.json", stats: stats
  end
end
