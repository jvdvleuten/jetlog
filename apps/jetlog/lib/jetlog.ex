defmodule Jetlog do
  @moduledoc """
  Jetlog keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  def test() do
    stress_test(0)
  end

  def stress_test(max) do
    Enum.each(0..max, fn x ->
      id = Ecto.UUID.generate()
      {:ok, _pid} = Jetlog.Logbook.Entry.Supervisor.start_child(id)

      Enum.each(0..Enum.random(0..1000), fn y ->
        Jetlog.Logbook.Entry.merge_event(
          id,
          %Jetlog.Logbook.Entry.Event{
            id: Ecto.UUID.generate(),
            body: %Jetlog.Logbook.Entry.Event.FlightnumberChanged{
              flightnumber: "KL#{x}#{y}",
              flightnumber_v: y
            },
            timestamp: DateTime.utc_now()
          }
        )
      end)
    end)

    :ok
  end
end
