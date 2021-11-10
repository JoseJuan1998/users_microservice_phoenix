defmodule Hangman.Token do

  @doc """
  Create token for given data
  """
  @spec auth_sign(map()) :: binary()
  def auth_sign(data) do
    Phoenix.Token.sign(HangmanWeb.Endpoint, "auth", data)
  end

  @spec refresh_sign(map()) :: binary()
  def refresh_sign(data) do
    Phoenix.Token.sign(HangmanWeb.Endpoint, "refresh", data)
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

  @spec verify_refresh(String.t()) :: {:ok, any()} | {:error, :unauthenticated}
  def verify_refresh(token) do
    Phoenix.Token.verify(HangmanWeb.Endpoint, "refresh", token, max_age: 86400)
  end
end
