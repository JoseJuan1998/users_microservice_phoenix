defmodule HangmanWeb.UserErrorController do
  use HangmanWeb, :controller

  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  def call(conn, {:error, changeset = %Ecto.Changeset{}}) do
    errors = errors_on(changeset)
    case Map.fetch(errors, :id) do
      :error ->
        conn
        |> put_status(400)
        |> json(errors)
      {:ok, _error} ->
        conn
        |> put_status(404)
        |> json(errors)
    end
  end

  def call(conn, {:error, error}) do
    conn
      |> put_status(400)
      |> json(%{error: error})
  end
end
