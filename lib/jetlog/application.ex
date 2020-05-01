defmodule Jetlog.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Jetlog.Repo, []},
      {Jetlog.Logbook.Entry.Supervisor, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Jetlog.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
