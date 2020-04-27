defmodule Jetlog.EctoLogbookEvent do
  use Ecto.Type
  def type, do: :map

  defmacro __using__(_options) do
    quote do
      def __tagged_ecto_logbook_event, do: :ok
    end
  end

  def list_tagged_modules do
    {:ok, modules} = :application.get_key(Application.get_application(__MODULE__), :modules)

    modules
    |> Enum.filter(fn m ->
      m.__info__(:functions) |> Enum.any?(&match?({:__tagged_ecto_logbook_event, 0}, &1))
    end)
  end

  def cast({name, body}) do
    require IEx
    IEx.pry()

    struct(name)
    |> name.changeset(body)
    |> Ecto.Changeset.apply_changes()
  end

  def load(data) when is_map(data) do
    require IEx
    IEx.pry()
    name = data["name"] |> String.to_existing_atom()
    {:ok, cast({name, data["body"]})}
  end

  def dump(%name{} = event) when is_map(event) do
    require IEx
    IEx.pry()
    data = %{name: name, body: Map.from_struct(event)}
    {:ok, data}
  end
end
