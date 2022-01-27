defmodule HangmanWeb.Auth.Guardian do
  use Guardian, otp_app: :hangman
  alias Hangman.Accounts
  alias Hangman.Accounts.Credential

  def subject_for_token(user, _claims), do: {:ok, to_string((user.id))}

  def authenticate(email, password) do
    case Accounts.authenticate_by_email_password(email, password) do
      {:ok, user} ->
        create_token(user)
      {:error, :unauthorized} ->
        {:error, "Wrong password"}
      {:error, :not_found} ->
        {:error, "User not found"}
      {:error, :not_active} ->
        {:error, "Verify your email, check your mailbox"}
      {:error, :not_password} ->
        {:error, "Password can't be blank"}
      {:error, :not_email} ->
        {:error, "Email can't be blank"}
    end
  end

  def email_authenticate_password(params) do
    case Accounts.reset_password(params) do
      %Credential{} = cred ->
        create_token_email(cred.user)
      %Ecto.Changeset{} = changeset ->
        {:error, changeset}
    end
  end

  def email_authenticate_activate(params) do
    case Accounts.create_user(params) do
      {:ok, user} ->
        create_token_email(user)
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  def resource_from_claims(claims) do
    {:ok,
    %{"id" => claims["sub"]}
    |> Accounts.get_user()}
  end

  def test_token_auth(user) do
    create_token(user)
  end

  def test_token_email(user) do
    create_token_email(user)
  end

  defp create_token(user) do
   {:ok, token, _claims} = encode_and_sign(user)
   {:ok, token, user}
  end

  defp create_token_email(user) do
    {:ok, token, _claims} = encode_and_sign(user, %{typ: "email"})
    {:ok, token, user}
  end
end
