defmodule Ghauth do
  @moduledoc """
  Ghauth allows using Github as PKI
  """

  alias Ghauth.{User, Client, Acl}

  @type username :: String.t()
  @type key :: String.t() | tuple

  @doc false
  @spec acl(String.t()) :: Acl.t()
  def acl(s), do: Acl.compile(s)

  @doc false
  @spec match?(username, Acl.t(), Client.t()) :: boolean
  def match?(username, acl, client) do
    username
    |> User.new()
    |> User.fetch_orgs(client)
    |> Acl.match?(acl, client)
  end

  @doc """
  Returns true if public key match one of user's one on Github account
  """
  @spec match_key?(username, key, Client.t()) :: boolean
  def match_key?(username, key, client) when is_binary(key) do
    decoded =
      key
      |> :public_key.ssh_decode(:public_key)
      |> hd()
      |> elem(0)

    match_key?(username, decoded, client)
  end

  def match_key?(username, key, client) do
    match_keys =
      username
      |> Client.user_keys(client)
      |> Enum.map(& &1["key"])
      |> Enum.join("\n")
      |> :public_key.ssh_decode(:public_key)
      |> Enum.map(&elem(&1, 0))
      |> MapSet.new()

    MapSet.member?(match_keys, key)
  end
end
