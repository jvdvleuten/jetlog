defmodule JetlogTest do
  alias Jetlog.Logbook.Entry.Event
  use ExUnit.Case, async: true
  doctest Jetlog

  test "changing flightnumber" do
    state = %Jetlog.Logbook.Entry{}
    event = %Event.FlightnumberChanged{flightnumber: "KL123", flightnumber_v: 0}
    new_state = Event.FlightnumberChanged.apply(event |> Event.create(), state)
    assert new_state.flightnumber == "KL1234"
  end
end
