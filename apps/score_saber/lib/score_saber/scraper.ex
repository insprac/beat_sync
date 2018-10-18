defmodule ScoreSaber.Scraper do
  alias ScoreSaber.Model.{Song, Score, User}

  @type id :: integer | String.t
  @type html_string :: String.t
  @type html_element :: tuple
  @type error :: :empty | :invalid | :failed | :fail_scrape

  @spec scrape_song(id, html_string) :: {:ok, Song.t} :: {:error, error}
  def scrape_song(_, nil), do: {:error, :empty}
  def scrape_song(_, ""), do: {:error, :empty}
  def scrape_song(score_saber_id, html) do
    case scrape_song_heading(html) do
      {:ok, title, author, difficulty} ->
        case scrape_song_details(html) do
          {:ok, id, status, star_difficulty, max_score} ->
            link = ScoreSaber.HTTP.build_url("/leaderboard/#{score_saber_id}")

            top_score = case scrape_top_score(html) do
              {:ok, score} -> score
              {:error, error} -> nil
            end

            song = %Song{
              id: "#{id}",
              score_saber_id: score_saber_id,
              link: link,
              title: title,
              status: status,
              author: author,
              difficulty: difficulty,
              star_difficulty: star_difficulty,
              max_score: max_score,
              top_score: top_score
            }

            {:ok, song}
          {:error, _} ->
            {:error, :failed}
        end
      {:error, _} ->
        {:error, :failed}
    end
  end

  @spec scrape_song_heading(html_string)
  :: {:ok, String.t, String.t, String.t} | {:error, error}
  defp scrape_song_heading(html) do
    case find_song_heading(html) do
      {"h4", _, [raw_title, {"span", _, [difficulty]}, raw_author]} ->
        title = String.slice(raw_title, 11..-3)
        author = String.slice(raw_author, 5..-1)

        {:ok, title, author, difficulty}
      _ ->
        {:error, :fail_scrape}
    end
  end

  @spec scrape_song_details(html_string) :: {:ok, String.t} | {:error, error}
  defp scrape_song_details(html) do
    case find_song_details(html) do
      {_, _, [
        {"p", _, [{"a", [{"href", bsaber_link}], _}]},
        _,
        {"b", _, [raw_status]},
        _,
        _,
        {"b", _, [raw_max_score]},
        _,
        _,
        {"b", _, [raw_star_difficulty]},
        _
      ]} ->
        id = bsaber_link |> String.split("/") |> List.last()
        status = String.downcase(raw_status || "")
        star_difficulty = parse_raw_star_difficulty(raw_star_difficulty)
        max_score = parse_raw_score(raw_max_score)

        {:ok, id, status, star_difficulty, max_score}
      _ ->
        {:error, :fail_scrape}
    end
  end

  @spec scrape_top_score(html_string) :: {:ok, Score.t} | {:error, error}
  def scrape_top_score(html) do
    case find_top_score(html) do
      {"tr", _, [
        _,
        _,
        {"td", _, [
          {"a", [{"href", user_path}], [
            {"img", [{"src", flag_path}], _},
            raw_user_name
          ]}
        ]},
        {"td", _, [raw_score]},
        _,
        {"td", _, [raw_accuracy]},
        {"td", _, [raw_pp]}
      ]} ->
        user_id = String.split(user_path || "", "/") |> List.last()
        user_name = String.trim(raw_user_name)
        user_link = ScoreSaber.HTTP.build_url(user_path)
        score = parse_raw_score(raw_score)
        accuracy = parse_raw_accuracy(raw_accuracy)
        pp = parse_raw_pp(raw_pp)

        score = %Score{
          rank: 1,
          score: score,
          accuracy: accuracy,
          pp: pp,
          user: %User{
            id: user_id,
            name: user_name,
            link: user_link
          }
        }

        {:ok, score}
      res ->
        {:error, :fail_scrape}
    end
  end

  @spec find_song_heading(html_string) :: html_element | nil
  defp find_song_heading(html) do
    Floki.find(html, "div.row .col h4")
    |> Enum.find(fn heading ->
      case heading do
        {"h4", _, [_, {"span", _, [_]}, _]} -> true
        _ -> false
      end
    end)
  end

  @spec find_song_details(html_string) :: html_element | nil
  defp find_song_details(html) do
    Floki.find(html, ".card .card-body")
    |> Enum.find(fn card ->
      case card do
        {_, _, [{"p", _, [{"a", _, _}]} | _]} -> true
        _ -> false
      end
    end)
  end

  @spec find_top_score(html_string) :: html_element | nil
  defp find_top_score(html) do
    Floki.find(html, ".card table tbody tr")
    |> Enum.find(fn score ->
      case score do
        {"tr", _, [_, _, {"td", _, [{"a", _, [{"img", _, _}, _]}]} | _]} ->
          true
        _ ->
          false
      end
    end)
  end

  defp parse_raw_score(raw_score) do
    case String.replace(raw_score || "", ",", "") |> Integer.parse() do
      {score, _} -> score
      :error -> 0
    end
  end

  defp parse_raw_accuracy(raw_accuracy) do
    case Float.parse(raw_accuracy) do
      {accuracy, _} -> accuracy
      _ -> 0.0
    end
  end

  def parse_raw_pp(raw_pp) do
    case Float.parse(raw_pp) do
      {pp, _} -> pp
      _ -> 0.0
    end
  end

  def parse_raw_star_difficulty(raw_star_difficulty) do
    case String.slice(raw_star_difficulty, 1..-3) |> Float.parse() do
      {star_difficulty, _} -> star_difficulty
      _ -> 0.0
    end
  end
end
