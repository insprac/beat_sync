defmodule Crawler do
  use GenServer
  alias Crawler.Listener
  alias Crawler.Model.CrawlerState

  @type song_id :: integer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, CrawlerState.cast(opts))
  end

  def all(pid), do: GenServer.call(pid, :all)

  def all_pending(pid), do: GenServer.call(pid, :all_pending)

  def all_processing(pid), do: GenServer.call(pid, :all_processing)

  def add(pid, id) when is_integer(id), do: GenServer.cast(pid, {:add, [id]})
  def add(pid, ids) when is_list(ids), do: GenServer.cast(pid, {:add, ids})

  def init(state) do
    schedule_spawn(state)

    {:ok, state}
  end

  def handle_call(:all, _from, state) do
    {:reply, state.pending ++ state.processing, state}
  end

  def handle_call(:all_pending, _from, state) do
    {:reply, state.pending, state}
  end

  def handle_call(:all_processing, _from, state) do
    {:reply, state.processing, state}
  end

  def handle_cast({:add, ids}, state) do
    pending = state.pending ++ ids
    Listener.call(self(), state, {:update_pending, length(pending)})
    {:noreply, %{state | pending: pending}}
  end

  def handle_info(:spawn, %CrawlerState{pending: []} = state) do
    {:noreply, state}
  end
  def handle_info(:spawn, state) do
    if length(state.processing) < state.spawn_limit do
      [id | pending] = state.pending

      pid = self()

      spawn(fn ->
        Listener.call(pid, state, {:start_process, id})

        case Crawler.Fetch.fetch(id) do
          {:ok, song} ->
            Listener.call(pid, state, {:end_process, {:ok, id, song}})
          {:error, error} ->
            Listener.call(pid, state, {:end_process, {:error, id}})
        end

        Process.send(pid, {:done, id}, [])
      end)

      processing = [id | state.processing]

      Listener.call(self(), state, {:update_pending, length(pending)})
      Listener.call(self(), state, {:update_processing, length(processing)})

      schedule_spawn(state)

      {:noreply, %{state | pending: pending, processing: processing}}
    else
      schedule_spawn(state)

      {:noreply, state}
    end
  end

  def handle_info({:done, id}, state) do
    case Enum.find_index(state.processing, &(&1 == id)) do
      nil ->
        {:noreply, state}
      index ->
        processing = List.delete_at(state.processing, index)

        Listener.call(self(), state, {:update_processing, length(processing)})

        {:noreply, %{state | processing: processing}}
    end
  end

  def schedule_spawn(%CrawlerState{spawn_frequency: duration}) do
    Process.send_after(self(), :spawn, duration)
  end
end
