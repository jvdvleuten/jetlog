import Config

config :jetlog, Jetlog.Repo,
  database: "jetlog_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  migration_primary_key: [name: :id, type: :binary_id]

# loggers: []

config :jetlog,
  ecto_repos: [Jetlog.Repo]

config :logger, level: :info

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
