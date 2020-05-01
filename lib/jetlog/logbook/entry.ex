defmodule Jetlog.Logbook.Entry.Supervisor do
  use DynamicSupervisor

  def start_link(_options) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_child(aggregate_id) do
    spec = {Jetlog.Logbook.Entry, aggregate_id}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end

defmodule Jetlog.Logbook.Database.Ecto do
  alias Jetlog.Logbook.Entry
  require Ecto.Query

  def get_events(aggregate_id) do
    Entry.Event
    |> Ecto.Query.where(aggregate_id: ^aggregate_id)
    |> Ecto.Query.order_by(asc: :sequence)
    |> Jetlog.Repo.all()
  end

  def save_events(events) do
    with multi <- Ecto.Multi.new() do
      events
      |> Enum.reduce(multi, &insert/2)
      |> Jetlog.Repo.transaction()
    end
  end

  defp insert(event, multi) do
    Ecto.Multi.insert(multi, event.id, event)
  end
end

defmodule Jetlog.Logbook.Entry do
  alias Jetlog.Logbook.Entry
  use GenServer, restart: :temporary
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field(:flightnumber, :string)
    field(:flightnumber_v, :integer, default: 0)
  end

  def changeset(entry, params \\ %{}) do
    entry
    |> Ecto.Changeset.cast(params, [:flightnumber, :flightnumber_v])
  end

  defp server_name(aggregate_id) do
    {:via, :syn, aggregate_id}
  end

  # API

  def start_link(aggregate_id) do
    GenServer.start_link(__MODULE__, aggregate_id, name: server_name(aggregate_id))
  end

  def merge_event(aggregate_id, event) do
    GenServer.cast(server_name(aggregate_id), {:merge_event, event})
  end

  # GenServer

  def init(aggregate_id) do
    events = Jetlog.Logbook.Database.Ecto.get_events(aggregate_id)
    IO.inspect(events)
    {:ok, state} = apply_events(events)

    aggregate = %{id: aggregate_id, events: events, state: state}

    {:ok, aggregate}
  end

  def apply_events(events, state \\ %__MODULE__{}) do
    IO.puts("APPLY EVENTS")

    Enum.reduce(events, state, &Entry.Event.apply/2)
    |> changeset()
    |> Ecto.Changeset.apply_action(:apply_events)
  end

  def handle_cast({:merge_event, event}, aggregate) do
    {:ok, merged_events} = Entry.Event.merge(event, aggregate)

    {:ok, new_state} = apply_events(merged_events, aggregate.state)

    {:ok, _changed} = Jetlog.Logbook.Database.Ecto.save_events(merged_events)

    new_aggregate =
      aggregate
      |> Map.put(:state, new_state)
      |> Map.put(:events, aggregate.events ++ merged_events)

    {:noreply, new_aggregate}
  end
end
