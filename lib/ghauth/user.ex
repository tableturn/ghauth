defmodule Ghauth.User do
  @moduledoc false

  alias Ghauth.Client

  defstruct login: nil, orgs: nil

  @type t :: %__MODULE__{
          login: String.t(),
          orgs: Map.t() | nil
        }

  @doc false
  @spec new(String.t()) :: t
  def new(username) when is_binary(username) do
    %__MODULE__{
      login: username
    }
  end

  @doc false
  @spec fetch_orgs(t, Client.t()) :: t
  def fetch_orgs(%__MODULE__{orgs: nil, login: username} = user, client) do
    orgs =
      username
      |> Client.orgs(client)
      |> Enum.map(&{&1["login"], nil})
      |> Enum.into(%{})

    %{user | orgs: orgs}
  end

  def fetch_orgs(user, _client), do: user
end
