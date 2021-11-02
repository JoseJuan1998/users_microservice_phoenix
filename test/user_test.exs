defmodule Hangman.UserTest do
  use Hangman.DataCase
  alias Hangman.Accounts
  alias Hangman.Accounts.{User, Credentials}

  ## MIX_ENV=test mix coveralls

  setup do
    stored_user = Accounts.create_user(%{name: "Pedro", credential: %{email: "pedro@cordage.io", password: "Qwerty2021", password_confirmation: "Qwerty2021", admin: false}})
    {:ok, got_user} = stored_user
    {:ok, user: got_user}
  end

  test "create user successfully" do
    user = %User{}
    changeset = Accounts.change_user(user, %{name: "Zuli", credential: %{email: "zuli@cordage.io", password: "Qwerty1010", password_confirmation: "Qwerty1010", admin: false}})
    assert changeset.valid? == true
    {:ok, _} = Accounts.create_user(%{name: "Zuli", credential: %{email: "zuli@cordage.io", password: "Qwerty1010", password_confirmation: "Qwerty1010", admin: false}})
  end

  test "create user unsuccessfully" do
    user = %User{}
    changeset = Accounts.change_user(user, %{name: "Zuli", credential: %{email: "zulicordage.io", password: "Qwerty1010", password_confirmation: "Qwerty1010", admin: false}})
    assert changeset.valid? == false
  end

  test "search user successfully", %{user: user} do
    user = Accounts.get_user(user.id)
    assert user.name == "Pedro"
  end

  test "search all users successfully" do
    users = Accounts.list_users()
    assert users != []
  end

  test "search all users unsuccessfully", %{user: user} do
    Accounts.delete_user(user)
    users = Accounts.list_users()
    assert users == []
  end

  test "delete user successfully", %{user: user} do
    Accounts.delete_user(user)
    users = Accounts.list_users()
    assert users == []
  end

  test "update user successfully", %{user: user} do
    updated_user = Accounts.update_user(user, %{name: "Alex", credential: %{id: user.id, email: "alex@cordage.io", password: "", password_confirmation: "", admin: true}})
    {:ok, user2} = updated_user
    assert user2.name != user.name && user2.id == user.id
  end
end
