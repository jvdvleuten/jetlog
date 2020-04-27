defmodule Jetlog.LogbookEvent do
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: false}
  schema "logbook_events" do
    field(:aggregate_id, :binary_id)
    field(:sequence, :integer)
    field(:body, Jetlog.EctoLogbookEvent)
    field(:timestamp, :utc_datetime_usec)
  end
end
