# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :zongora,
  ecto_repos: [Zongora.Repo]

# Configures the endpoint
config :zongora, Zongora.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "zA/x5XOGXIXQFxlemUvFZevjakIUF/1DceVD7YBWTUxRdDC1ZCEUVfkCPyCaU9tv",
  render_errors: [view: Zongora.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Zongora.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
