defmodule Ghauth.AclTest do
  use ExUnit.Case

  doctest Ghauth.Acl, import: true

  alias Ghauth.{Acl, Organization, User, Team, Client}

  @client %Client{}

  @acl1 "org1"
  @acl2 "org1/admin"
  @acl3 "org2/admin,org2/dev,org1/admin"

  @team_org1_admin %Team{
    name: "admin",
    id: 1,
    members: ["pierre"]
  }

  @team_org1_users %Team{
    name: "users",
    id: 2,
    members: ["jean", "pierre"]
  }

  @team_org2_admin %Team{
    name: "admin",
    id: 3,
    members: ["john"]
  }

  @team_org2_users %Team{
    name: "users",
    id: 4,
    members: ["john", "peter"]
  }

  @org1 %Organization{
    login: "org1",
    teams: %{
      "admin" => @team_org1_admin,
      "users" => @team_org1_users
    }
  }

  @org2 %Organization{
    login: "org2",
    teams: %{
      "admin" => @team_org2_admin,
      "users" => @team_org2_users
    }
  }

  @user_pierre %User{
    login: "pierre",
    orgs: %{"org1" => @org1, "org2" => @org2}
  }

  @user_jean %User{
    login: "jean",
    orgs: %{"org1" => @org1}
  }

  @user_john %User{
    login: "john",
    orgs: %{"org2" => @org2}
  }

  @user_peter %User{
    login: "peter",
    orgs: %{"org2" => @org2}
  }

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
      assert MapSet.member?(teams2, "admin")
      assert MapSet.member?(teams2, "dev")
    end
  end

  describe ".match?/3" do
    test "\"#{@acl1}\"" do
      acl = Acl.compile(@acl1) |> acl_faker()
      assert Acl.match?(@user_pierre, acl, @client)
      assert Acl.match?(@user_jean, acl, @client)
      refute Acl.match?(@user_peter, acl, @client)
      refute Acl.match?(@user_john, acl, @client)
    end

    test "\"#{@acl2}\"" do
      acl = Acl.compile(@acl2) |> acl_faker()
      assert Acl.match?(@user_pierre, acl, @client)
      refute Acl.match?(@user_jean, acl, @client)
      refute Acl.match?(@user_peter, acl, @client)
      refute Acl.match?(@user_john, acl, @client)
    end

    test "\"#{@acl3}\"" do
      acl = Acl.compile(@acl3) |> acl_faker()
      assert Acl.match?(@user_pierre, acl, @client)
      refute Acl.match?(@user_jean, acl, @client)
      refute Acl.match?(@user_peter, acl, @client)
      assert Acl.match?(@user_john, acl, @client)
    end
  end

  defp acl_faker(acl), do: Enum.map(acl, &org_faker/1)

  defp org_faker({%Organization{login: "org1"}, teams}), do: {@org1, teams}
  defp org_faker({%Organization{login: "org2"}, teams}), do: {@org2, teams}
end
