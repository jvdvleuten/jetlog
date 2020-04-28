defmodule Jetlog.EctoLogbookEvent do
  @before_compile Jetlog.EctoLogbookEventHelper
  use Ecto.Type
  def type, do: :map

  defmacro __using__(_options) do
    quote do
      current_config = Application.get_env(:jetlog, :__ecto_logbook_events, %{})
      name = Module.split(__MODULE__) |> List.last()
      new_config = current_config |> Map.put(name, __MODULE__)
      :ok = Application.put_env(:jetlog, :__ecto_logbook_events, new_config, persistent: true)
      :ok
    end
  end

  defp get_fully_qualified_name(name) do
    Application.get_env(:jetlog, :__ecto_logbook_events) |> Map.get(name)
  end

  def cast({name, body}) do
    full_name = get_fully_qualified_name(name)

    struct(full_name)
    |> full_name.changeset(body)
    |> Ecto.Changeset.apply_changes()
  end

  def load(data) when is_map(data) do
    {:ok, cast({data["name"], data["body"]})}
  end

  def dump(%name{} = event) when is_map(event) do
    name = Module.split(name) |> List.last()
    data = %{name: name, body: Map.from_struct(event)}
    {:ok, data}
  end
end
