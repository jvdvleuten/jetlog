defmodule JetlogWeb.EntriesController do
  use JetlogWeb, :controller

  def index(conn, params) do
    IO.inspect(params)
    json(conn, :ok)
  end

  def create(conn, params) do
    IO.inspect(params)
    json(conn, :ok)
  end
end
