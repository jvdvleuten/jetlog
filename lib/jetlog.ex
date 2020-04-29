defmodule Jetlog do
  def stress_test(max) do
    Enum.each(0..max, fn x ->
      id = Ecto.UUID.generate()
      {:ok, _pid} = Jetlog.LogbookEntry.Supervisor.start_child(id)

      Enum.each(0..Enum.random(1..max), fn y ->
        Jetlog.LogbookEntry.merge_events(id, [
          %Jetlog.LogbookEvent{
            id: Ecto.UUID.generate(),
            body: %Jetlog.LogbookEntry.FlightnumberChanged{
              flightnumber: "KL#{x}#{y}",
              flightnumber_v: y
            },
            timestamp: DateTime.utc_now()
          },
          %Jetlog.LogbookEvent{
            id: Ecto.UUID.generate(),
            body: %Jetlog.LogbookEntry.FlightnumberChanged{
              flightnumber: "KL#{x}#{y}",
              flightnumber_v: y
            },
            timestamp: DateTime.utc_now()
          }
        ])
      end)
    end)

    :ok
  end
end
