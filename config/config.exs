use Mix.Config

config :celeste,
  ecto_repos: [Celeste.Repo]

# Configures the endpoint
config :celeste, Celeste.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "zA/x5XOGXIXQFxlemUvFZevjakIUF/1DceVD7YBWTUxRdDC1ZCEUVfkCPyCaU9tv",
  render_errors: [view: Celeste.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Celeste.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
