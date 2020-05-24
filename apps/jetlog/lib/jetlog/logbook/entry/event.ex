defmodule Jetlog.Logbook.Entry.Event do
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: false}
  schema "logbook_events" do
    field(:aggregate_id, :binary_id)
    field(:sequence, :integer)
    field(:body, Jetlog.Logbook.Entry.EctoEvent)
    field(:timestamp, :utc_datetime_usec)
  end

  def changeset(event, params \\ %{}) do
    event
    |> Ecto.Changeset.cast(params, [:id, :body, :timestamp])
    |> Ecto.Changeset.validate_required([:aggregate_id, :sequence, :body, :timestamp])
    |> Ecto.Changeset.validate_number(:sequence, greater_than_or_equal_to: 0)
  end

  def create(body) do
    %Jetlog.Logbook.Entry.Event{
      id: Ecto.UUID.generate(),
      timestamp: DateTime.utc_now(),
      body: body
    }
  end

  def apply(event = %__MODULE__{}, state) do
    %event_name{} = event.body
    event_name.apply(event, state)
  end

  def merge(event = %__MODULE__{}, aggregate) do
    %event_name{} = event.body

    {:ok, new_events} = event_name.merge(event, aggregate)

    sanitized_events =
      Enum.map(new_events, fn event ->
        {:ok, event} = sanitize(event, aggregate)
        event
      end)

    {:ok, sanitized_events}
  end

  defp sanitize(event, aggregate) do
    {:ok, _event} =
      changeset(
        %__MODULE__{
          aggregate_id: aggregate.id,
          sequence: length(aggregate.events)
        },
        %{id: event.id, body: event.body, timestamp: event.timestamp}
      )
      |> Ecto.Changeset.apply_action(:merge)
  end
end
