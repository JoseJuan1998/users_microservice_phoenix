defmodule Hangman.SessionTest do
  use Hangman.DataCase

  alias Hangman.Accounts

  describe "[Unit] create_session():" do
    setup do
      {:ok, created_user} = Accounts.create_user(%{name: "Pedro", credential: %{email: "pedro@cordage.io"}})
      {:ok, updated_user} = Accounts.update_password(%{id: created_user.id, password: "Qwerty2021", password_confirmation: "Qwerty2021"})
      {:ok, user: updated_user}
    end

    test "Returns the 'info' of the user logged", %{user: user} do
      authenticated = Accounts.authenticate_by_email_password(user.email, "Qwerty2021")
      assert not is_nil(authenticated)
    end

    test "Error when 'email' is empty" do
      assert {:error, :not_email} == Accounts.authenticate_by_email_password(nil, "Qwerty2021")
    end

    test "Error when 'email' is wrong" do
      assert {:error, :not_found} == Accounts.authenticate_by_email_password("wrong@email.com", "Qwerty2021")
    end

    test "Error when 'password' is empty", %{user: user} do
      assert {:error, :not_password} == Accounts.authenticate_by_email_password(user.email, nil)
    end

    test "Error when 'password' is wrong", %{user: user} do
      assert {:error, :unauthorized} == Accounts.authenticate_by_email_password(user.email, "Qwerty2020")
    end
  end

  describe "ERROR [Unit] create_session():" do
    setup do
      {:ok, created_user} = Accounts.create_user(%{name: "Pedro", credential: %{email: "pedro@cordage.io"}})
      {:ok, user: created_user}
    end

    test "Error when 'user' is not active" do
      assert {:error, :not_active} == Accounts.authenticate_by_email_password("pedro@cordage.io", "Qwerty2020")
    end
  end
end
