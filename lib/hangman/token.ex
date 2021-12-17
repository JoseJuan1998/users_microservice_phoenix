defmodule Hangman.Token do

  @doc """
  Create token for given data
  """
  @spec auth_sign(map()) :: binary()
  def auth_sign(data) do
    Phoenix.Token.sign("VAMWT81mVrqjNQ8qSNlnQIls5PFnZFHe", "auth", data)
  end

  @spec email_sign(map()) :: binary()
  def email_sign(data) do
    Phoenix.Token.sign("VAMWT81mVrqjNQ8qSNlnQIls5PFnZFHe", "email", data)
  end

  @doc """
  Verify given token by:
  - Verify token signature
  - Verify expiration time
  """
  @spec verify_auth(String.t()) :: {:ok, any()} | {:error, :unauthenticated}
  def verify_auth(token) do
    Phoenix.Token.verify("VAMWT81mVrqjNQ8qSNlnQIls5PFnZFHe", "auth", token, max_age: 3600)
  end

  # coveralls-ignore-start
  @spec verify_email(String.t()) :: {:ok, any()} | {:error, :unauthenticated}
  def verify_email(token) do
    Phoenix.Token.verify("VAMWT81mVrqjNQ8qSNlnQIls5PFnZFHe", "email", token, max_age: 86400*7)
  end
  # coveralls-ignore-stop
end
