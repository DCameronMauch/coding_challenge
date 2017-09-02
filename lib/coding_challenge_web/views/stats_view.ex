defmodule CodingChallengeWeb.StatsView do
  @moduledoc false
  

  def render("stats.json", %{stats: stats}) do
    stats
  end
end
