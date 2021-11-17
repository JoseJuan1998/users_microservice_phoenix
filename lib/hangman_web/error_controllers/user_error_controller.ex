defmodule HangmanWeb.UserErrorController do
  use HangmanWeb, :controller

  def call(conn, {:error, changeset = %Ecto.Changeset{}}) do
    cond do
      changeset.action == :update or changeset.action == :delete->
        errors = changeset.errors
        new_errors = Enum.map(errors, fn {e, r} -> {e, elem(r, 0)} end)
        final_errors = Enum.into(new_errors, %{})
        conn
          |> put_status(400)
          |> json(final_errors)
      not is_nil(changeset.errors[:id]) ->
        errors = changeset.errors
        new_errors = Enum.map(errors, fn {e, r} -> {e, elem(r, 0)} end)
        final_errors = Enum.into(new_errors, %{})
        conn
          |> put_status(400)
          |> json(final_errors)
      not is_nil(changeset.errors[:email]) ->
        errors = changeset.errors
        new_errors = Enum.map(errors, fn {e, r} -> {e, elem(r, 0)} end)
        final_errors = Enum.into(new_errors, %{})
        conn
          |> put_status(400)
          |> json(final_errors)
      changeset.action == :insert || changeset.changes.credential.action == :insert ->
        errors = changeset.changes.credential.errors ++ changeset.errors
        new_errors = Enum.map(errors, fn {e, r} -> {e, elem(r, 0)} end)
        final_errors = Enum.into(new_errors, %{})
        conn
          |> put_status(400)
          |> json(final_errors)
    end
  end

  def call(conn, {:error, error}) do
    conn
      |> put_status(400)
      |> json(%{error: error})
  end

  # def call(conn, _) do
  #   conn
  #     |> put_status(500)
  #     |> json(%{error: "Unknown error: please call Hangman Team"})
  # end
end
