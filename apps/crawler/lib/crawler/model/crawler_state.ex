defmodule Crawler.Model.CrawlerState do
  @spawn_frequency 100 # Every 100ms
  @spawn_limit 50

  defstruct(
    listener: nil,
    pending: [],
    processing: [],
    spawn_frequency: @spawn_frequency,
    spawn_limit: @spawn_limit
  )

  @type t :: %__MODULE__{
    listener: module,
    pending: list(integer),
    processing: list(integer),
    spawn_frequency: integer,
    spawn_limit: integer
  }

  @spec cast(Keyword.t) :: t
  def cast(opts) do
    %__MODULE__{
      listener: Keyword.get(opts, :listener, nil),
      pending: Keyword.get(opts, :pending, []),
      processing: [],
      spawn_frequency: Keyword.get(opts, :spawn_frequency, @spawn_frequency),
      spawn_limit: Keyword.get(opts, :spawn_limit, @spawn_limit)
    }
  end
end
