# Ghauth

GitHub API provides access to user SSH public keys and membership
(organizations, teams).

This library allows you to use this API as a PKI.

## Example

### Creates a personal access token

See [GitHub documentation](https://github.com/settings/tokens)

Needed scopes: `repo`, `admin:public_key`

### Check user public key

```elixir
client = Ghauth.new(%{access_token: "abcdef1234567890"})
Ghauth.match?("toto", "ssh-rsa XYZ...", client)
```

### Check if user matches organization/team

``` elixir
client = Ghauth.new(%{access_token: "abcdef1234567890"})
acl = Ghauth.acl("tableturn/admins,tableturn/users,mozilla")
Ghauth.match?("toto", acl, client)
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ghauth` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ghauth, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ghauth](https://hexdocs.pm/ghauth).
