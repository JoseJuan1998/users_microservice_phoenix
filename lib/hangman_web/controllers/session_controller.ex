defmodule HangmanWeb.SessionController do
    use HangmanWeb, :controller
    alias Hangman.Accounts
    import Plug.Conn.Status, only: [code: 1]
    use PhoenixSwagger

    action_fallback HangmanWeb.UserErrorController

    swagger_path :create_session do
        post("/api/login")
        summary("Create session")
        description("Return the id of the user if it's found and the password is valid and create a session")
        response(code(:ok), "Success")
        produces("application/json")
        deprecated(false)
    end

    def create_session(conn, %{"email" => email, "password" => password}) do
        case Accounts.authenticate_by_email_password(email, password) do
            {:ok, user} ->
                conn
                |> put_status(200)
                |> put_session(:user_id, user.id)
                |> configure_session(renew: true)
                |> render("session.json", %{user_id: user.id})
            {:error, :unauthorized} ->
                {:error, "Wrong password"}
            {:error, :not_found} ->
                {:error, "User not found"}
        end
    end

    swagger_path :delete_session do
        delete("/api/logout")
        summary("Delete session")
        description("Delete the session")
        response(code(205), "No Response")
        produces("application/json")
        deprecated(false)
    end

    def delete_session(conn, _) do
        conn
        |> put_status(205)
        |> configure_session(drop: true)
        |> text("Session ended")
    end
end
