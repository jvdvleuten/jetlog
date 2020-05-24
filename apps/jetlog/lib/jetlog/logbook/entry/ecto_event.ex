defmodule Jetlog.Logbook.Entry.EctoEvent do
  @before_compile Jetlog.Logbook.Entry.EctoEventHelper
  use Ecto.Type
  def type, do: :map

  # This macro makes sure that only modules using the EctoLogbookEvent module
  # are used when dumping or casting from/to the database or an external source
  defmacro __using__(_options) do
    quote do
      current_config = Application.get_env(:jetlog, :__ecto_logbook_entry_events, %{})
      event_name = Module.split(__MODULE__) |> List.last()
      new_config = current_config |> Map.put(event_name, __MODULE__)

      :ok =
        Application.put_env(:jetlog, :__ecto_logbook_entry_events, new_config, persistent: true)
    end
  end

  defp get_fully_qualified_event_name(event_name) do
    Application.get_env(:jetlog, :__ecto_logbook_entry_events) |> Map.get(event_name)
  end

  def cast(body = %event_name{}) when is_map(body) do
    {:ok, _event} =
      body
      |> event_name.changeset()
      |> Ecto.Changeset.apply_action(:cast)
  end

  def cast({event_name, body}) do
    full_event_name = get_fully_qualified_event_name(event_name)

    {:ok, _event} =
      struct(full_event_name)
      |> full_event_name.changeset(body)
      |> Ecto.Changeset.apply_action(:cast)
  end

  def load(data) when is_map(data) do
    {:ok, _event} = cast({data["name"], data["body"]})
  end

  def dump(%event_name{} = event) when is_map(event) do
    event_name = Module.split(event_name) |> List.last()
    data = %{name: event_name, body: Map.from_struct(event)}
    {:ok, data}
  end
end
