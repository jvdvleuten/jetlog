defmodule Jetlog.LogbookEvent do
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: false}
  schema "logbook_events" do
    field(:aggregate_id, :binary_id)
    field(:sequence, :integer)
    field(:body, Jetlog.EctoLogbookEvent)
    field(:timestamp, :utc_datetime_usec)
  end

  def changeset(event, params \\ %{}) do
    event
    |> Ecto.Changeset.cast(params, [:aggregate_id, :sequence, :body, :timestamp])
    |> Ecto.Changeset.validate_required([:aggregate_id, :sequence, :body, :timestamp])
    |> Ecto.Changeset.validate_number(:sequence, greater_than_or_equal_to: 0)
  end
end
