defmodule Jetlog.Logbook.Entry.EctoEventHelper do
  defmacro __before_compile__(_env) do
    quote do
      Application.put_env(:jetlog, :__ecto_logbook_entry_events, %{}, persistent: true)
    end
  end
end
