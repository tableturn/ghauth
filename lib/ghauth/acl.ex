defmodule Ghauth.Acl do
  @moduledoc """
  """

  alias Ghauth.{User, Client, Organization, Team}

  @type teams :: [Team.t()] | :_
  @type matcher :: {Organization.t(), teams}
  @type t :: [matcher]

  @doc """
  Compile string to ACL

  Example:

  iex> compile("tableturn")
  [{%Ghauth.Organization{login: "tableturn"}, :_}]
  """
  @spec compile(String.t()) :: t
  def compile(s) do
    s
    |> String.split(",")
    |> Enum.reduce(%{}, &parse_teams/2)
    |> Enum.map(&to_acl/1)
  end

  @doc """
  Return true if acl matches
  """
  @spec match?(User.t(), t, Client.t()) :: boolean
  def match?(_user, [], _client), do: false

  def match?(%User{} = user, [{org, teams} | rest], client) do
    if Organization.match?(org, user, client) do
      match_teams?(org, teams, user, rest, client)
    else
      false
    end
  end

  ###
  ### Priv
  ###
  defp match_teams?(_org, :_, _user, _acl, _client), do: true

  defp match_teams?(org, teams, user, acl, client) do
    org = Organization.fetch_teams(org, client)

    teams
    |> Enum.any?(fn teamname ->
      org
      |> Organization.team(teamname)
      |> Team.match?(user, client)
    end)
    |> if do
      true
    else
      match?(user, acl, client)
    end
  end

  defp parse_teams(s, acc) do
    {orgname, teams} =
      s
      |> String.split("/")
      |> case do
        [orgname] ->
          {orgname, Map.get(acc, orgname, MapSet.new())}

        [orgname, team] ->
          teams = Map.get(acc, orgname, MapSet.new())
          {orgname, MapSet.put(teams, team)}
      end

    Map.put(acc, orgname, teams)
  end

  defp to_acl({orgname, teams}) do
    if MapSet.size(teams) > 0 do
      {Organization.new(orgname), teams}
    else
      {Organization.new(orgname), :_}
    end
  end
end
