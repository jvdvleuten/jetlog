defmodule Jetlog.Repo do
  use Ecto.Repo,
    otp_app: :jetlog,
    adapter: Ecto.Adapters.Postgres
end
