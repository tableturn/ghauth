defmodule Ghauth.AclTest do
  use ExUnit.Case

  doctest Ghauth.Acl, import: true

  alias Ghauth.{Acl, Organization}

  @acl1 "org1"
  @acl2 "org1/admin"
  @acl3 "org1,org2/users,org2/dev,org1/admin"

  describe ".compile/1" do
    test @acl1 do
      assert [{%Organization{login: "org1"}, :_}] == Acl.compile(@acl1)
    end

    test @acl2 do
      [{org, teams}] = Acl.compile(@acl2)

      assert match?(%Organization{login: "org1"}, org)
      assert MapSet.member?(teams, "admin")
    end

    test @acl3 do
      [{org1, teams1}, {org2, teams2}] = Acl.compile(@acl3)

      assert match?(%Organization{login: "org1"}, org1)
      assert MapSet.member?(teams1, "admin")

      assert match?(%Organization{login: "org2"}, org2)
      assert MapSet.member?(teams2, "users")
      assert MapSet.member?(teams2, "dev")
    end
  end
end
