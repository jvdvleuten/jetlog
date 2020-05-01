defmodule Jetlog.Logbook.Entry.Event.LogbookEntryCreated do
  use Ecto.Schema
  use Jetlog.Logbook.Entry.EctoEvent
  @primary_key false
  embedded_schema do
    field(:user_id, :binary_id)
  end

  def changeset(event, params \\ %{}) do
    event
    |> Ecto.Changeset.cast(params, [:user_id])
    |> Ecto.Changeset.validate_required([:user_id])
  end
end
