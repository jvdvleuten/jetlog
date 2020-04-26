# Swarm.register_name("test1", Jetlog.LogbookEntry.Supervisor, :start_child, ["test1"])
#
defmodule Jetlog.LogbookEntry.Supervisor do
  use DynamicSupervisor

  def start_link(_options) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_child(aggregate_id) do
    spec = {Jetlog.LogbookEntry, [aggregate_id]}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end

defmodule Jetlog.LogbookEntry do
  use GenServer, restart: :temporary

  @moduledoc """
  This is the worker process, in this case, it simply posts on a
  random recurring interval to stdout.
  """
  def start_link(aggregate_id) do
    GenServer.start_link(__MODULE__, aggregate_id)
  end

  def init(_name) do
    {:ok, :rand.uniform(5_000), 0}
  end

  # called when a handoff has been initiated due to changes
  # in cluster topology, valid response values are:
  #
  #   - `:restart`, to simply restart the process on the new node
  #   - `{:resume, state}`, to hand off some state to the new process
  #   - `:ignore`, to leave the process running on its current node
  #
  def handle_call({:swarm, :begin_handoff}, _from, delay) do
    IO.puts("#{inspect(self())} :begin_handoff")
    {:reply, {:resume, delay}, delay}
  end

  # called after the process has been restarted on its new node,
  # and the old process' state is being handed off. This is only
  # sent if the return to `begin_handoff` was `{:resume, state}`.
  # **NOTE**: This is called *after* the process is successfully started,
  # so make sure to design your processes around this caveat if you
  # wish to hand off state like this.
  def handle_cast({:swarm, :end_handoff, delay}, _state) do
    IO.puts("#{inspect(self())} :end_handoff")
    {:noreply, delay}
  end

  # called when a network split is healed and the local process
  # should continue running, but a duplicate process on the other
  # side of the split is handing off its state to us. You can choose
  # to ignore the handoff state, or apply your own conflict resolution
  # strategy
  def handle_cast({:swarm, :resolve_conflict, _delay}, state) do
    IO.puts("#{inspect(self())} :resolve_conflict")
    {:noreply, state}
  end

  def handle_info(:timeout, delay) do
    IO.puts("#{delay} says hi! #{inspect(self())}")
    Process.send_after(self(), :timeout, delay)
    {:noreply, delay}
  end

  # this message is sent when this process should die
  # because it is being moved, use this as an opportunity
  # to clean up
  def handle_info({:swarm, :die}, state) do
    IO.puts("#{inspect(self())} :die")
    {:stop, :shutdown, state}
  end
end
