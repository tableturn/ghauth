defmodule Ghauth.Team do
  @moduledoc false

  alias Ghauth.{User, Client}

  defstruct name: nil, id: nil, members: nil

  @type t :: %__MODULE__{
          name: String.t(),
          id: String.t(),
          members: list | nil
        }

  @doc false
  @spec new(String.t(), String.t()) :: t
  def new(id, name) do
    %__MODULE__{
      id: id,
      name: name
    }
  end

  @doc false
  @spec match?(t, User.t(), Client.t()) :: boolean
  def match?(nil, _user, _client), do: false

  def match?(%__MODULE__{} = team, %User{login: username}, client) do
    team
    |> fetch_members(client)
    |> Map.get(:members)
    |> Enum.member?(username)
  end

  @doc false
  @spec fetch_members(t, Client.t()) :: t
  def fetch_members(%__MODULE__{id: id, members: nil} = team, client) do
    members =
      id
      |> Client.team_members(client)
      |> Enum.map(& &1["login"])

    %{team | members: members}
  end

  def fetch_members(team, _client), do: team
end
