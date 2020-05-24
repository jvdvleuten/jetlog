defmodule Jetlog.Logbook.Entry.Event.FlightnumberMerged do
  use Ecto.Schema
  use Jetlog.Logbook.Entry.EctoEvent
  @primary_key false
  embedded_schema do
    field(:flightnumber, :string)
    field(:flightnumber_v, :string)
  end

  def changeset(event, params \\ %{}) do
    event
    |> Ecto.Changeset.cast(params, [:flightnumber, :flightnumber_v])
    |> Ecto.Changeset.validate_required([:flightnumber])
    |> Ecto.Changeset.validate_required([:flightnumber_v])
  end

  def apply_event(event, state) do
    state
    |> Map.put(:flightnumber, event.body.flightnumber)
    |> Map.put(:flightnumber_v, state.flightnumber_v + 1)
  end
end
