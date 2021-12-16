defmodule Hangman.Accounts do
  import Ecto.Query, warn: false
  alias Hangman.Repo
  alias Hangman.Accounts.Credential
  alias Hangman.Accounts.User
  alias Hangman.Accounts.EmailToken

  def count_users(attrs \\ %{}) do
    query = cond do
      not is_nil(attrs["char"]) ->
        from u in User, join: c in Credential, on: u.id == c.user_id, where: like(fragment("upper(?)", u.name), ^"%#{String.trim(String.upcase(attrs["char"]))}%") or like(fragment("upper(?)",u.lastname), ^"%#{String.trim(String.upcase(attrs["char"]))}%") or like(fragment("upper(?)", c.email), ^"%#{String.trim(String.upcase(attrs["char"]))}%"), select: count(u)
      true ->
        from u in User, select: count(u)
    end
    Repo.one(query)
  end

  def list_users(attrs \\ %{}) do
    query = cond do
      not is_nil(attrs["np"]) and not is_nil(attrs["nr"]) ->
        get_pagination(attrs)
      true ->
        from u in User, offset: 0, limit: 0, select: u
    end
    Repo.all(query)
    |> Repo.preload(:credential)
  end

  def get_user(attrs \\ %{}) do
    attrs
    |> User.found_changeset()
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.create_changeset(attrs)
    |> Repo.insert()
  end

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

  def reset_password(attrs \\ %{}) do
    attrs
    |> Credential.get_changeset_email()
  end

  def delete_user(attrs) do
    attrs
    |> User.delete_changeset()
    |> Repo.delete()
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    user
    |> User.create_changeset(attrs)
  end

  def authenticate_by_email_password(email, given_password) do
    cond do
      not is_nil(email) ->
        cred = Repo.get_by(Credential, email: email) |> Repo.preload(:user)
        authenticate_active(cred, given_password)
      true ->
        {:error, :not_email}
    end
  end

  def create_email_token(attrs \\ %{}) do
    attrs
    |> EmailToken.create_changeset()
    |> Repo.insert()
  end

  def delete_email_token(attrs \\ %{}) do
    attrs
    |> EmailToken.delete_changeset()
    |> Repo.delete()
  end

  defp get_pagination(attrs) do
    cond do
      not is_nil(attrs["char"]) ->
        from u in User, join: c in Credential, on: u.id == c.user_id, where: like(fragment("upper(?)", u.name), ^"%#{String.trim(String.upcase(attrs["char"]))}%") or like(fragment("upper(?)",u.lastname), ^"%#{String.trim(String.upcase(attrs["char"]))}%") or like(fragment("upper(?)", c.email), ^"%#{String.trim(String.upcase(attrs["char"]))}%"), offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
      not is_nil(attrs["field"]) and not is_nil(attrs["order"]) ->
        get_field(attrs)
      true ->
        from u in User, order_by: [asc: u.name], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
    end
  end

  defp get_field(attrs) do
    case String.to_atom(String.downcase(attrs["field"])) do
      :name ->
        get_sorting(attrs)
      :lastname ->
        get_sorting(attrs)
      :email ->
        get_sorting_email(attrs)
      _other ->
        from u in User, order_by: [asc: u.name], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
    end
  end

  defp get_sorting(attrs) do
    case String.to_atom(String.upcase(attrs["order"])) do
      :ASC ->
        from u in User, order_by: ^[asc: String.to_atom(String.downcase(attrs["field"]))], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
      :DESC ->
        from u in User, order_by: ^[desc: String.to_atom(String.downcase(attrs["field"]))],offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
      _other ->
        from u in User, order_by: [asc: u.name], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
    end
  end

  defp get_sorting_email(attrs) do
    case String.to_atom(String.upcase(attrs["order"])) do
      :ASC ->
        from c in Credential, join: u in User, on: u.id == c.user_id, order_by: ^[asc: String.to_atom(String.downcase(attrs["field"]))], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
      :DESC ->
        from c in Credential, join: u in User, on: u.id == c.user_id, order_by: ^[desc: String.to_atom(String.downcase(attrs["field"]))], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
      _other ->
        from u in User, order_by: [asc: u.name], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
    end
  end

  defp authenticate_active(cred, given_password) do
    cond do
      cred && cred.active ->
        authenticate_password(cred, given_password)
      cred ->
        {:error, :not_active}
      true ->
        {:error, :not_found}
    end
  end

  defp authenticate_password(cred, given_password) do
    cond do
      not is_nil(given_password) ->
        authenticate_login(cred, given_password)
      true ->
        {:error, :not_password}
    end
  end

  defp authenticate_login(cred, given_password) do
    cond do
      Argon2.verify_pass(given_password, cred.password_hash) ->
        {:ok, cred.user}
      true ->
        {:error, :unauthorized}
    end
  end
end
