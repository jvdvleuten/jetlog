defmodule Jetlog.Logbook.Entry.Event.FlightnumberChanged do
  use Ecto.Schema
  use Jetlog.Logbook.Entry.EctoEvent
  @primary_key false

  embedded_schema do
    field(:flightnumber, :string)
    field(:flightnumber_v, :integer)
  end

  def changeset(event, params \\ %{}) do
    event
    |> Ecto.Changeset.cast(params, [:flightnumber, :flightnumber_v])
    |> Ecto.Changeset.validate_required([:flightnumber])
    |> Ecto.Changeset.validate_required([:flightnumber_v])
  end

  def apply(event, state) do
    state
    |> Map.put(:flightnumber, event.body.flightnumber)
    |> Map.put(:flightnumber_v, state.flightnumber_v + 1)
  end

  def merge(event, aggregate) do
    if aggregate.state.flightnumber_v > event.body.flightnumber_v do
      merge_event =
        %Jetlog.Logbook.Entry.Event.FlightnumberMerged{
          flightnumber: aggregate.state.flightnumber,
          flightnumber_v: aggregate.state.flightnumber_v + 1
        }
        |> Jetlog.Logbook.Entry.Event.create()

      {:ok, [event, merge_event]}
    else
      {:ok, [event]}
    end
  end
end
