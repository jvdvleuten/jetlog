defmodule Jetlog.EctoLogbookEvent do
  use Ecto.Type
  def type, do: :map

  def cast({name, body}) do
    struct(name)
    |> name.changeset(body)
    |> Ecto.Changeset.apply_changes()
  end

  def load(data) when is_map(data) do
    name = data["name"] |> String.to_existing_atom()
    {:ok, cast({name, data["body"]})}
  end

  def dump(%name{} = event) when is_map(event) do
    data = %{name: name, body: Map.from_struct(event)}
    {:ok, data}
  end
end
