defmodule Jetlog do
  def stress_test() do
    Enum.each(0..1, fn x ->
      id = Ecto.UUID.generate()
      {:ok, pid} = Jetlog.LogbookEntry.Supervisor.start_child(id)

      Enum.each(0..Enum.random(1..1), fn y ->
        Jetlog.LogbookEntry.merge_events(id, [
          %{
            id: Ecto.UUID.generate(),
            body: %Jetlog.LogbookEntry.FlightnumberChanged{
              flightnumber: "KL#{x}#{y}"
            },
            timestamp: DateTime.utc_now()
          }
        ])
      end)
    end)

    :ok
  end
end
