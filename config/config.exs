import Config

config :jetlog, Jetlog.Repo,
  database: "jetlog_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  migration_primary_key: [name: :id, type: :binary_id]

config :jetlog,
  ecto_repos: [Jetlog.Repo]
