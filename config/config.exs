import Config

config :jetlog, Jetlog.Repo,
  database: "jetlog_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :jetlog,
  ecto_repos: [Jetlog.Repo]
