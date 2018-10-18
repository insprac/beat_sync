defmodule ScoreSaber do
  def get_song(id) do
    case ScoreSaber.HTTP.get_song(id) do
      {:ok, %HTTPoison.Response{body: body}} ->
        ScoreSaber.Scraper.scrape_song(id, body)
      _ ->
        {:error, :http_error}
    end
  end
end
