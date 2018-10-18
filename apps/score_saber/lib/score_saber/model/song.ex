defmodule ScoreSaber.Model.Song do
  defstruct(
    id: nil,
    score_saber_id: nil,
    link: nil,
    title: "",
    author: "",
    status: "",
    max_score: 0,
    difficulty: "",
    star_difficulty: 0.0,
    top_score: nil
  )

  @type t :: %__MODULE__{
    id: String.t,
    score_saber_id: String.t,
    link: String.t,
    title: String.t,
    author: String.t,
    status: String.t,
    max_score: integer,
    difficulty: String.t,
    star_difficulty: float,
    top_score: ScoreSaber.Model.Score.t
  }
end
