# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :jetlog,
  ecto_repos: [Jetlog.Repo]

config :jetlog_web,
  ecto_repos: [Jetlog.Repo],
  generators: [context_app: :jetlog]

config :jetlog, Jetlog.Repo, migration_primary_key: [name: :id, type: :binary_id]

# Configures the endpoint
config :jetlog_web, JetlogWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "DMo8fSXhazj9AdtXTiQV4YLefLemHHD2naoZ/6HoQ130cDEYXaUDclGOP4F7VYjc",
  render_errors: [view: JetlogWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Jetlog.PubSub,
  live_view: [signing_salt: "hZHu7Uxo"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :libcluster,
  # debug: false,
  topologies: [
    gossip_example: [
      strategy: Elixir.Cluster.Strategy.Gossip,
      config: [
        port: 45892,
        if_addr: "0.0.0.0",
        multicast_if: "0.0.0.0",
        multicast_addr: "230.1.1.251",
        multicast_ttl: 1,
        secret: "somepassword"
      ]
    ]
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
