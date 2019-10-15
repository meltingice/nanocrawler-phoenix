# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :nanocrawler, NanocrawlerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "dAWUeayvOlOtbz8iJ4eO2VTIWAwCXqK/j3uTsTlNIdaGpGN5RtWS0L/8DvHPrmuW",
  render_errors: [view: NanocrawlerWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Nanocrawler.PubSub, adapter: Phoenix.PubSub.PG2],
  nano: [rpc_host: "http://10.0.1.78:55000"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
