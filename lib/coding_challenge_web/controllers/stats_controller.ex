defmodule CodingChallengeWeb.StatsController do
  @moduledoc false
  
  use CodingChallengeWeb, :controller

  def stats(conn, _params) do
    render conn, "stats.json", stats: %{data: []}
  end
end
