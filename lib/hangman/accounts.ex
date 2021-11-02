defmodule Hangman.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  # import Comeonin.Argon2, only: [checkpw: 2, dummy_checkpw: 0]
  alias Hangman.Repo
  alias Hangman.Accounts.Credential
  alias Hangman.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
    |> Repo.preload(:credential)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      ** (Ecto.NoResultsError)

  """
  def get_user(id) do
    Repo.get(User, id)
    |> Repo.preload(:credential)
  end


  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:credential, with: &Credential.changeset/2)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs \\ %{}) do

    cond do
      attrs["credential"]["password"] != nil && attrs["credential"]["email"] == nil->
        user
        |> User.changeset(attrs)
        |> Ecto.Changeset.cast_assoc(:credential, with: &Credential.registration_changeset/2)
        |> Repo.update()
      (attrs["credential"]["active"] != nil || attrs["credential"]["admin"] != nil) && (attrs["credential"]["email"] == nil) ->
        user
        |> User.changeset(attrs)
        |> Ecto.Changeset.cast_assoc(:credential, with: &Credential.changeset/2)
        |> Repo.update()
      attrs["credential"] == nil && attrs["name"] != nil->
        user
        |> User.changeset(attrs)
        |> Repo.update()
      attrs["credential"]["email"] != nil ->
        {:error, "Imposible update email"}
      true ->
        {:error, "No params received"}
    end
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    cred_changeset =
      if attrs["credential"]["password"] == nil do
        &Credential.changeset/2
      else
        &Credential.registration_changeset/2
      end
    user
    |> User.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:credential, with: cred_changeset)
  end

  @doc """
  Athenticate a user.

  ## Examples

      iex> Repo.get_by(Credential, email: email) |> Repo.preload(:user)
      {:ok, %User{}}

      Argon2.verify_pass(given_password, cred.password_hash)

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def authenticate_by_email_password(email, given_password) do
    cred = Repo.get_by(Credential, email: email) |> Repo.preload(:user)

    cond do
      cred && Argon2.verify_pass(given_password, cred.password_hash) ->
        {:ok, cred.user}
      cred ->
        {:error, :unauthorized}
      true ->
        {:error, :not_found}
    end
  end
end
