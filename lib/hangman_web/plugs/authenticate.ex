defmodule HangmanWeb.Authenticate do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> get_token()
    |> Hangman.Token.verify_auth()
    |> case do
      {:ok, user_id} -> assign(conn, :current_user, user_id)
      _unauthorized -> assign(conn, :current_user, nil)
    end
  end

  def authenticate_api_user(conn, _opts) do
    if Map.get(conn.assigns, :current_user) do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> redirect(external: "http://hangmangame1.eastus.cloudapp.azure.com/login")
      |> halt()
    end
  end

  def get_token(conn) do
    case get_req_header(conn, "authorization") do
      [token_auth] -> token_auth
      _ -> nil
    end
  end
end
