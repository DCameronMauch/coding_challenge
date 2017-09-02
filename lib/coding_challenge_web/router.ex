defmodule CodingChallengeWeb.Router do
  use CodingChallengeWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CodingChallengeWeb do
    pipe_through :api

    get "/", StatsController, :stats
  end
end
