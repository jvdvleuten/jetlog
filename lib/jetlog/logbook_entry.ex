# Swarm.register_name("test1", Jetlog.LogbookEntry.Supervisor, :start_child, ["test1"])
#
defmodule Jetlog.LogbookEntry.Supervisor do
  use DynamicSupervisor

  def start_link(_options) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_child(aggregate_id) do
    spec = {Jetlog.LogbookEntry, aggregate_id}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end

defmodule Jetlog.LogbookEntry.FlightnumberChanged do
  use Ecto.Schema
  use Jetlog.EctoLogbookEvent
  @primary_key false
  embedded_schema do
    field(:flightnumber, :string)
  end

  def changeset(event, params \\ %{}) do
    event
    |> Ecto.Changeset.cast(params, [:flightnumber])
    |> Ecto.Changeset.validate_required([:flightnumber])
  end
end

defmodule Jetlog.LogbookEntry do
  use GenServer, restart: :temporary
  use Ecto.Schema
  require Ecto.Query

  @primary_key false
  embedded_schema do
    field(:flightnumber, :string)
    field(:flightnumber_v, :integer)
  end

  def changeset(event, params \\ %{}) do
    event
    |> Ecto.Changeset.cast(params, [:flightnumber, :flightnumber_v])
    |> Ecto.Changeset.validate_required([:flightnumber])
  end

  defp server_name(aggregate_id) do
    {:via, :syn, aggregate_id}
  end

  def start_link(aggregate_id) do
    GenServer.start_link(__MODULE__, aggregate_id, name: server_name(aggregate_id))
  end

  def init(aggregate_id) do
    events =
      Jetlog.LogbookEvent
      |> Ecto.Query.where(aggregate_id: ^aggregate_id)
      |> Jetlog.Repo.all()

    state = Enum.reduce(events, %{}, &apply_event/2)
    aggregate = %{id: aggregate_id, events: events, state: state}
    {:ok, aggregate}
  end

  def merge_events(aggregate_id, events) do
    GenServer.cast(server_name(aggregate_id), {:merge_events, events})
  end

  def handle_cast({:merge_events, events}, aggregate) do
    merged_events = merge_events(events, aggregate, [])

    Jetlog.Repo.insert_all(Jetlog.LogbookEvent, merged_events)
    new_state = Enum.reduce(merged_events, aggregate.state, &apply_event/2)

    new_aggregate =
      aggregate
      |> Map.put(:state, new_state)
      |> Map.put(:events, aggregate.events ++ merged_events)

    {:noreply, new_aggregate}
  end

  def apply_event(event = %{body: %Jetlog.LogbookEntry.FlightnumberChanged{} = body}, state) do
    state
    |> Map.put(:flightnumber, body.flightnumber)

    # |> Map.put(:flightnumber_v, increase_vector(state, :flightnumber_v))
  end

  def merge_events([head | tail], aggregate, events) do
    new_events =
      merge_event(head, aggregate)
      |> Map.put(:aggregate_id, aggregate.id)
      |> Map.put(:sequence, length(aggregate.events))

    merge_events(tail, aggregate, [new_events | events])
  end

  def merge_events([], _aggregate, events) do
    events
  end

  def merge_event(event = %{body: %Jetlog.LogbookEntry.FlightnumberChanged{}}, _state) do
    event
  end
end
