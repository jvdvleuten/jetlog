defmodule Jetlog.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies)

    children = [
      {Cluster.Supervisor, [topologies, [name: Jetlog.ClusterSupervisor]]},
      # Start the Ecto repository
      {Jetlog.Repo, []},
      # Start the PubSub system
      {Phoenix.PubSub, name: Jetlog.PubSub},
      # Start a worker by calling: Jetlog.Worker.start_link(arg)
      {Jetlog.Logbook.Entry.Supervisor, []}
      # {Jetlog.Worker, arg}
    ]

    opts = [strategy: :one_for_one, name: Jetlog.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
