defmodule Crawler.Listener do
  @moduledoc """
  Crawler Listener helpers.

  ## Example implementation

      defmodule MyApp.CrawlerListener do
        @spec handle(pid, Crawler.Listener.event) :: any
        def handle(_crawler, {:start_process, id}) do
          IO.puts("Processing: " <> id)
        end

        def handle(_crawler, {:end_process, {:ok, id, song}}) do
          IO.puts("Processed song: " <> song.name)
          IO.inspect(song)
        end

        def handle(_crawler, event) do
          IO.inspect({:listener_unknown_event, event})
        end
      end

  """

  @type count :: integer
  @type event :: 
    {:start_process, Crawler.song_id} | 
    {:end_process, {:ok, Crawler.song_id, map} | {:error, Crawler.song_id}} |
    {:update_pending, count} |
    {:update_processing, count}

  @spec call(pid, Crawler.Model.CrawlerState, event) :: :ok
  def call(crawler, state, event) do
    if is_atom(state.listener) do
      spawn(fn -> apply(state.listener, :handle, [crawler, event]) end)
    end

    :ok
  end
end
