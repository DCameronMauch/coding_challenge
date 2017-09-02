# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :coding_challenge, CodingChallengeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "XRHN4d2AJLY9gaDAOecLQvgBAgz2PD/x9lgEtG0DSCr59tDe2i0/0PupYTxKP7aa",
  render_errors: [view: CodingChallengeWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: CodingChallenge.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
