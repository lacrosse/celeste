use Mix.Config

config :celeste,
  ecto_repos: [Celeste.Repo]

# Configures the endpoint
config :celeste, CelesteWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "zA/x5XOGXIXQFxlemUvFZevjakIUF/1DceVD7YBWTUxRdDC1ZCEUVfkCPyCaU9tv",
  render_errors: [view: Celeste.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Celeste.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :celeste, Celeste.Social.Borkfm,
  api_key: ""

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :guardian, Guardian,
  allowed_algos: ["HS512"],
  issuer: "Celeste",
  ttl: { 30, :days },
  allowed_drift: 2000,
  verify_issuer: true,
  serializer: Celeste.GuardianSerializer

import_config "#{Mix.env}.exs"
