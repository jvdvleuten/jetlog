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
    field(:flightnumber_v, :string)
  end

  def changeset(event, params \\ %{}) do
    event
    |> Ecto.Changeset.cast(params, [:flightnumber, :flightnumber_v])
    |> Ecto.Changeset.validate_required([:flightnumber])
    |> Ecto.Changeset.validate_required([:flightnumber_v])
  end
end

defmodule Jetlog.LogbookEntry.FlightnumberMerged do
  use Ecto.Schema
  use Jetlog.EctoLogbookEvent
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
end

defmodule Jetlog.LogbookEntry do
  use GenServer, restart: :temporary
  use Ecto.Schema
  require Ecto.Query

  @primary_key false
  embedded_schema do
    field(:flightnumber, :string)
    field(:flightnumber_v, :integer, default: 0)
  end

  def changeset(event, params \\ %{}) do
    event
    |> Ecto.Changeset.cast(params, [:flightnumber, :flightnumber_v])
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

    state = Enum.reduce(events, %Jetlog.LogbookEntry{}, &apply_event/2)
    aggregate = %{id: aggregate_id, events: events, state: state}
    {:ok, aggregate}
  end

  def merge_events(aggregate_id, events) do
    GenServer.cast(server_name(aggregate_id), {:merge_events, events})
  end

  def handle_cast({:merge_events, events}, aggregate) do
    merged_events =
      merge_events(events, aggregate, [])
      |> Enum.map(fn changeset ->
        {:ok, event} = changeset |> Ecto.Changeset.apply_action(:insert)
        event
      end)

    {:ok, _changed} =
      merged_events
      |> Enum.reduce(Ecto.Multi.new(), fn event, multi ->
        Ecto.Multi.insert(multi, event.id, event)
      end)
      |> Jetlog.Repo.transaction()

    new_state = Enum.reduce(merged_events, aggregate.state, &apply_event/2)

    new_aggregate =
      aggregate
      |> Map.put(:state, new_state)
      |> Map.put(:events, aggregate.events ++ merged_events)

    {:noreply, new_aggregate}
  end

  def apply_event(%{body: %Jetlog.LogbookEntry.FlightnumberChanged{} = body}, state) do
    state
    |> Map.put(:flightnumber, body.flightnumber)
    |> Map.put(:flightnumber_v, state.flightnumber_v + 1)
  end

  def apply_event(%{body: %Jetlog.LogbookEntry.FlightnumberMerged{} = body}, state) do
    state
    |> Map.put(:flightnumber, body.flightnumber)
    |> Map.put(:flightnumber_v, state.flightnumber_v + 1)
  end

  def merge_events([], _aggregate, events) do
    events
  end

  def merge_events([head | tail], aggregate, events) do
    {:ok, new_events} = merge_event(head, aggregate)

    {aggregate, new_events} =
      new_events
      |> Enum.reduce({aggregate, []}, fn event, {aggregate, new_events} ->
        new_event =
          Jetlog.LogbookEvent.changeset(event, %{
            aggregate_id: aggregate.id,
            sequence: length(aggregate.events)
          })

        {:ok, new_event_data} = Ecto.Changeset.apply_action(new_event, :merge)

        new_state = apply_event(new_event_data, aggregate.state)

        new_aggregate =
          aggregate
          |> Map.put(:state, new_state)
          |> Map.put(:events, aggregate.events ++ [new_event])

        {new_aggregate, new_events ++ [new_event]}
      end)

    merge_events(tail, aggregate, events ++ new_events)
  end

  def merge_event(event = %{body: %Jetlog.LogbookEntry.FlightnumberChanged{}}, aggregate) do
    if aggregate.state.flightnumber_v > event.body.flightnumber_v do
      merge_event =
        %Jetlog.LogbookEntry.FlightnumberMerged{
          flightnumber: aggregate.state.flightnumber,
          flightnumber_v: aggregate.state.flightnumber_v + 1
        }
        |> create_event()

      {:ok, [event, merge_event]}
    else
      {:ok, [event]}
    end
  end

  def create_event(body) do
    %Jetlog.LogbookEvent{id: Ecto.UUID.generate(), timestamp: DateTime.utc_now(), body: body}
  end
end
