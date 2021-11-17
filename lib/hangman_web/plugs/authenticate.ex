defmodule HangmanWeb.Authenticate do
  import Plug.Conn
  import Phoenix.Controller
  alias Hangman.Token

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> get_token()
    |> verify_token()
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

  def authenticate_api_email_user(conn, _opts) do
    if Map.get(conn.assigns, :current_user) do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> redirect(external: "http://hangmangame1.eastus.cloudapp.azure.com/remember")
      |> halt()
    end
  end

  defp verify_token(token) do
    case Token.verify_auth(token) do
      {:ok, user_id} -> {:ok, user_id}
      _unauthorized ->
        case Token.verify_email(token) do
          {:ok, user_id} -> {:ok, user_id}
          _unauthorized -> {:error, :invalid}
        end
    end
  end

  defp get_token(conn) do
    case get_req_header(conn, "authorization") do
      [token_auth] -> token_auth
      _ -> nil
    end
  end
end
