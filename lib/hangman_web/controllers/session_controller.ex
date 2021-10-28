defmodule HangmanWeb.SessionController do
    use HangmanWeb, :controller
    alias Hangman.Accounts
    import Plug.Conn.Status, only: [code: 1]
    use PhoenixSwagger

    action_fallback HangmanWeb.UserErrorController

    swagger_path :get_user do
        get("/api/login")
        summary("Validate user")
        description("Return the id of the user if it's found and the password is valid")
        response(code(:ok), "Success")
        produces("application/json")
        deprecated(false)
    end

    def authenticate_user(conn, %{"email" => email, "password" => password}) do
        case Accounts.authenticate_by_email_password(email, password) do
            {:ok, user} ->
                conn
                |> put_status(200)
                |> render("session.json", %{user_id: user.id})
            {:error, :unauthorized} ->
                {:error, "Wrong password"}
            {:error, :not_found} ->
                {:error, "User not found"}
        end
    end
end
