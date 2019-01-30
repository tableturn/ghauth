defmodule Ghauth.Client do
  @moduledoc """
  Lightweight wrapper for GitHub API
  """
  @user_agent {'user-agent', 'tt-infra'}

  defstruct auth: nil, endpoint: "https://api.github.com/"

  @type t :: %__MODULE__{}

  @doc false
  def new(%{access_token: _} = auth) do
    %__MODULE__{auth: auth}
  end

  @doc false
  @spec user_keys(String.t(), t) :: list | {:error, term}
  def user_keys(username, client) do
    get("users/#{username}/keys", client)
  end

  @doc false
  @spec orgs(String.t(), t) :: list | {:error, term}
  def orgs(username, client) do
    get("users/#{username}/orgs", client)
  end

  @doc false
  @spec org_teams(String.t(), t) :: list | {:error, term}
  def org_teams(org, client) do
    get("orgs/#{org}/teams", client)
  end

  @doc false
  @spec team_members(String.t(), t) :: list | {:error, term}
  def team_members(team_id, client) do
    get("teams/#{team_id}/members", client)
  end

  ###
  ### Priv
  ###
  defp get(path, %{endpoint: endpoint} = client) do
    url = endpoint <> path
    req = {'#{url}', headers(client)}

    :get
    |> :httpc.request(req, [], body_format: :binary)
    |> process_response()
  end

  defp headers(%{auth: %{access_token: token}}),
    do: [{'authorization', 'token #{token}'}, @user_agent]

  defp process_response({:error, _} = e), do: e

  defp process_response({:ok, {{_, 200, _}, _, body}}) do
    Poison.decode!(body)
  end

  defp process_response({:ok, {{_, status_code, _}, _, _}}) do
    {:error, status_code}
  end
end
