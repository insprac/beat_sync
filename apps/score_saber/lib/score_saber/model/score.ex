defmodule ScoreSaber.Model.Score do
  defstruct(
    rank: nil,
    user: nil,
    score: 0,
    accuracy: 0,
    pp: 0
  )

  @type t :: %__MODULE__{
    rank: integer,
    user: ScoreSaber.Model.User.t,
    score: integer,
    accuracy: integer,
    pp: integer
  }
end
