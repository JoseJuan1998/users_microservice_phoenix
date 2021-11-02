defmodule Hangman.UserTest do
  use Hangman.DataCase
  alias Hangman.Accounts
  alias Hangman.Accounts.{User, Credentials}

  ## MIX_ENV=test mix coveralls

  setup do
    stored_user = Accounts.create_user(%{name: "Pedro", credential: %{email: "pedro@cordage.io", admin: false, active: false}})
    {:ok, got_user} = stored_user
    {:ok, user: got_user}
  end

  test "create user successfully" do
    user = %User{}
    changeset = Accounts.change_user(user, %{name: "Zuli", credential: %{email: "zuli@cordage.io", admin: false, active: false}})
    assert changeset.valid? == true
    {:ok, user} = Accounts.create_user(%{name: "Zuli", credential: %{email: "zuli@cordage.io", admin: false, active: false}})
  end

  test "create user unsuccessfully" do
    user = %User{}
    changeset = Accounts.change_user(user, %{name: "Zuli", credential: %{email: "zulicordage.io", active: false, admin: false}})
    assert changeset.valid? == false
  end

  test "search user successfully", %{user: user} do
    user = Accounts.get_user(user.id)
    assert user != nil
  end

  test "search user unsuccessfully", %{user: user} do
    user = Accounts.get_user((user.id+1))
    assert user == nil
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

  test "update user name successfully", %{user: user} do
    updated_user = Accounts.update_user(user, %{"name" => "Alex"})
    {:ok, user2} = updated_user
    assert user2.name != user.name
  end

  test "update user password successfully", %{user: user} do
    updated_user = Accounts.update_user(user, %{"credential" => %{"id" => user.id, "password" => "Qwerty2021", "password_confirmation" => "Qwerty2021", "admin" => false, "active" => false}})
    {:ok, user2} = updated_user
    assert user2.credential.password_hash != nil
  end

  test "update user active successfully", %{user: user} do
    updated_user = Accounts.update_user(user, %{"credential" => %{"id" => user.id, "active" => true}})
    {:ok, user2} = updated_user
    assert user2.credential.active != user.credential.active
  end

  test "update user admin successfully", %{user: user} do
    updated_user = Accounts.update_user(user, %{"credential" => %{"id" => user.id, "admin" => true}})
    {:ok, user2} = updated_user
    assert user2.credential.admin != user.credential.admin
  end

  test "update user unsuccessfully because no params", %{user: user} do
    updated_user = Accounts.update_user(user, %{})
    assert updated_user != {:error, "Unknown error, call Hangman Team Support"}
  end

  test "update user unsuccessfully because email", %{user: user} do
    updated_user = Accounts.update_user(user, %{name: "Alex", credential: %{id: user.id, email: "alex@cordage.io" ,password: "", password_confirmation: "", admin: true}})
    assert updated_user != {:error, "Impossible update email"}
  end
end
