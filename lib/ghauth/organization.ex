defmodule Ghauth.Organization do
  @moduledoc false

  alias Ghauth.{User, Client, Team}

  defstruct login: nil, teams: nil

  @type t :: %__MODULE__{
          login: String.t(),
          teams: Map.t() | nil
        }

  @doc false
  @spec new(String.t()) :: t
  def new(org_name) when is_binary(org_name) do
    %__MODULE__{
      login: org_name
    }
  end

  @doc false
  @spec team(t, String.t()) :: Team.t()
  def team(%__MODULE__{teams: teams}, teamname) do
    Map.get(teams, teamname)
  end

  @doc false
  @spec match?(t, User.t(), Client.t()) :: boolean
  def match?(nil, _user, _client), do: false

  def match?(%__MODULE__{login: orgname}, %User{} = user, client) do
    user
    |> User.fetch_orgs(client)
    |> Map.get(:orgs)
    |> Map.keys()
    |> Enum.member?(orgname)
  end

  @doc false
  @spec fetch_teams(t, Client.t()) :: t
  def fetch_teams(%__MODULE__{teams: nil, login: name} = org, client) do
    teams =
      name
      |> Client.org_teams(client)
      |> Enum.map(&{&1["name"], Team.new(&1["id"], &1["name"])})

    %{org | teams: teams}
  end

  def fetch_teams(org, _client), do: org
end
