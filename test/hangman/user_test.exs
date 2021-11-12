defmodule Hangman.UserTest do
  use Hangman.DataCase

  alias Hangman.Accounts
  alias Hangman.Accounts.User

  ## MIX_ENV=test mix coveralls
  ## MIX_ENV=test mix coveralls.html

  # --- Unit Tests -------------------------------------------------------------------------------

  describe "[Unit] create_user():" do
    setup do
      stored_user = Accounts.create_user(%{name: "Pedro", credential: %{email: "pedro@cordage.io"}})
      {:ok, got_user} = stored_user
      {:ok, user: got_user}
    end

    test "Returns a user" do
      user = %User{}
      changeset = Accounts.change_user(user, %{name: "Zuli", credential: %{email: "zuli@cordage.io"}})
      assert changeset.valid? == true
    end

    test "Error when 'email' already exists" do
      {:error, changeset} = Accounts.create_user(%{name: "Pedro", credential: %{email: "pedro@cordage.io"}})
      assert changeset.valid? == false
    end

    test "Error when 'name' is empty" do
      user = %User{}
      changeset = Accounts.change_user(user, %{credential: %{email: "zuli@cordage.io"}})
      assert changeset.valid? == false
    end

    test "Error when 'email' is empty" do
      user = %User{}
      changeset = Accounts.change_user(user, %{name: "Zuli", credential: %{}})
      assert changeset.valid? == false
    end

    test "Error when 'email' is invalid format" do
      user = %User{}
      changeset = Accounts.change_user(user, %{name: "Zuli", credential: %{email: "zulicordage.io"}})
      assert changeset.valid? == false
    end

    test "Error when 'params' is empty" do
      user = %User{}
      changeset = Accounts.change_user(user, %{})
      assert changeset.valid? == false
    end
  end

  describe "[Unit] get_users():" do
    setup do
      stored_user = Accounts.create_user(%{name: "Pedro", credential: %{email: "pedro@cordage.io"}})
      {:ok, got_user} = stored_user
      {:ok, user: got_user}
    end

    test "Return all users" do
      users = Accounts.list_users()
      assert users != []
    end

    test "Error when 'users' is empty", %{user: user} do
      Accounts.delete_user(%{id: user.id})
      users = Accounts.list_users()
      assert users == []
    end
  end

  describe "[Unit] get_user():" do
    setup do
      stored_user = Accounts.create_user(%{name: "Pedro", credential: %{email: "pedro@cordage.io"}})
      {:ok, got_user} = stored_user
      {:ok, user: got_user}
    end

    test "Return one user", %{user: user} do
      user = Accounts.get_user(%{id: user.id})
      assert not is_nil(user)
    end

    test "Error when 'id' is wrong", %{user: user} do
      chg = Accounts.get_user(%{id: user.id+1})
      assert chg.valid? == false
    end
  end

  describe "[Unit] delete_user():" do
    setup do
      stored_user = Accounts.create_user(%{name: "Pedro", credential: %{email: "pedro@cordage.io"}})
      {:ok, got_user} = stored_user
      {:ok, user: got_user}
    end

    test "Return the user deleted", %{user: user} do
      user = Accounts.delete_user(%{id: user.id})
      assert not is_nil(user)
    end

    test "Error when 'id' is wrong", %{user: user} do
      {:error, chg} = Accounts.delete_user(%{id: user.id+1})
      assert chg.valid? == false
    end
  end

  describe "[Unit] update_name():" do
    setup do
      stored_user = Accounts.create_user(%{name: "Pedro", credential: %{email: "pedro@cordage.io"}})
      {:ok, got_user} = stored_user
      {:ok, user: got_user}
    end

    test "Return user name updated ", %{user: user} do
      {:ok, updated_user} = Accounts.update_name(%{id: user.id, name: "Pedrito"})
      assert not is_nil(updated_user)
    end

    test "Error when 'id' is wrong" do
      {:error, chg} = Accounts.update_name(%{name: "Juan"})
      assert chg.valid? == false
    end

    test "Error when 'name' is empty" do
      {:error, chg} = Accounts.update_name(%{})
      assert chg.valid? == false
    end
  end

  describe "[Unit] update_password():" do
    setup do
      stored_user = Accounts.create_user(%{name: "Pedro", credential: %{email: "pedro@cordage.io"}})
      {:ok, got_user} = stored_user
      {:ok, user: got_user}
    end

    test "Return user password updated", %{user: user} do
      {:ok, updated_user} = Accounts.update_password(%{id: user.id, password: "Qwerty2021", password_confirmation: "Qwerty2021"})
      assert not is_nil(updated_user)
    end

    test "Error when 'id' is empty" do
      {:error, chg} = Accounts.update_password(%{password: "Qwerty2021", password_confirmation: "Qwerty2021"})
      assert chg.valid? == false
    end

    test "Error when 'id' is wrong", %{user: user} do
      {:error, chg} = Accounts.update_password(%{id: user.id+1,password: "Qwerty2021", password_confirmation: "Qwerty2021"})
      assert chg.valid? == false
    end

    test "Error when 'password' is empty", %{user: user} do
      {:error, chg} = Accounts.update_password(%{id: user.id, password: "", password_confirmation: "Qwerty2021"})
      assert chg.valid? == false
    end

    test "Error when 'password' is invalid format", %{user: user} do
      {:error, chg} = Accounts.update_password(%{id: user.id, password: "qwerty2021", password_confirmation: "Qwerty2021"})
      assert chg.valid? == false
    end

    test "Error when 'password_confirmation' is empty", %{user: user} do
      {:error, chg} = Accounts.update_password(%{id: user.id, password: "Qwerty2021", password_confirmation: ""})
      assert chg.valid? == false
    end

    test "Error when 'password_confirmation' does not match", %{user: user} do
      {:error, chg} = Accounts.update_password(%{id: user.id, password: "Qwerty2021", password_confirmation: "Qwerty2020"})
      assert chg.valid? == false
    end
  end
end
