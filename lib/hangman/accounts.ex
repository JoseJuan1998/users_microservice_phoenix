defmodule Hangman.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
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
  def get_user(attrs \\ %{}) do
    attrs
    |> User.found_changeset()
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
    |> User.create_changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:credential, with: &Credential.create_changeset/2)
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

  def update_name(attrs \\ %{})  do
    attrs
    |> User.update_changeset()
    |> Repo.update()
  end

  def update_password(attrs \\ %{}) do
    attrs
    |> Credential.password_changeset()
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(attrs) do
    attrs
    |> User.delete_changeset()
    |> Repo.delete()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    user
    |> User.create_changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:credential, with: &Credential.create_changeset/2)
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
      cred && cred.active ->
        cond do
          cred.password_hash != nil ->
            cond do
              Argon2.verify_pass(given_password, cred.password_hash) ->
                {:ok, cred.user}
              true ->
                {:error, :unauthorized}
            end
          true ->
            {:error, :not_password}
        end
      cred ->
        {:error, :not_active}
      true ->
        {:error, :not_found}
    end
  end
end
