defmodule ScoreSaber.HTTP do
  @type id :: integer | String.t
  @type response :: {:ok, HTTPoison.Response.t} :: {:ok, HTTPoison.Error.t}

  @spec get_song(id) :: response
  def get_song(id) do
    get("/leaderboard/#{id}")
  end

  @spec host() :: String.t
  defp host, do: Application.get_env(:score_saber, :host)

  @spec get(String.t, Keyword.t, Keyword.t) :: response
  defp get(path, headers \\ [], options \\ []) do
    build_url(path) |> HTTPoison.get(headers, options)
  end

  @spec build_url(String.t) :: String.t
  def build_url(path), do: host() <> path
end
