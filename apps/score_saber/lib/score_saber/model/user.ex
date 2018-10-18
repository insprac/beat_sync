defmodule ScoreSaber.Model.User do
  defstruct(
    id: nil,
    name: "",
    link: nil
  )

  @type t :: %__MODULE__{
    id: String.t,
    name: String.t,
    link: String.t
  }
end
