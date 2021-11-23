defmodule Hangman.Token do

  @doc """
  Create token for given data
  """
  @spec auth_sign(map()) :: binary()
  def auth_sign(data) do
    Phoenix.Token.sign(HangmanWeb.Endpoint, "auth", data)
  end

  @spec email_sign(map()) :: binary()
  def email_sign(data) do
    Phoenix.Token.sign(HangmanWeb.Endpoint, "email", data)
  end

  @doc """
  Verify given token by:
  - Verify token signature
  - Verify expiration time
  """
  @spec verify_auth(String.t()) :: {:ok, any()} | {:error, :unauthenticated}
  def verify_auth(token) do
    Phoenix.Token.verify(HangmanWeb.Endpoint, "auth", token, max_age: 3600)
  end

  # coveralls-ignore-start
  @spec verify_email(String.t()) :: {:ok, any()} | {:error, :unauthenticated}
  def verify_email(token) do
    Phoenix.Token.verify(HangmanWeb.Endpoint, "email", token, max_age: 86400*7)
  end
  # coveralls-ignore-stop
end
