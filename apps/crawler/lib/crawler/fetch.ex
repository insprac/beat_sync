defmodule Crawler.Fetch do
  def fetch(id) do
    try do
      ScoreSaber.get_song(id)
    rescue
      _ -> {:error, :fail_fetch}
    end
  end
end
