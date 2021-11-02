defmodule HangmanWeb.SessionController do
    use HangmanWeb, :controller
    alias Hangman.Accounts
    import Plug.Conn.Status, only: [code: 1]
    use PhoenixSwagger

    action_fallback HangmanWeb.UserErrorController

    def swagger_definitions do
        %{
          User:
            swagger_schema do
              title("User")
              description("Managers for the words list")

              properties do
                id(:integer, "User ID")
                name(:string, "User name", required: true)
                credential(Schema.ref(:Credential))
                inserted_at(:string, "Creation timestamp", format: :datetime)
                updated_at(:string, "Update timestamp", format: :datetime)
              end
            end,
          Credential:
            swagger_schema do
              title("Credential")
              description("Managers credential")

              properties do
                id(:integer, "Credential ID")
                email(:string, "User Email", required: true)
                password_hash(:string)
                password(:string, "Virtual Password")
                password_confirmation(:string, "Virtual Password Confirmation")
                admin(:boolean, "User is a Super Manenger", required: true)
                active(:boolean, "User has verified email", required: true)
                user(Schema.ref(:User))
                inserted_at(:string, "Creation timestamp", format: :datetime)
                updated_at(:string, "Update timestamp", format: :datetime)
              end
            end,
        CreateSessionRequest:
        swagger_schema do
          title("CreateUserRequest")
          description("POST body for creating a user")
          property(:users, Schema.array(:User), "The users details")
          example(%{
              email: "juan@cordage.io",
              password: "Qwerty2021"
          })
        end,
        CreateSessionResponse:
            swagger_schema do
            title("CreateSessionResponse")
            description("Response and id")
            property(:users, Schema.array(:User), "The users details")
            example(%{
                user_id: 1
            })
            end
        }
      end

    swagger_path :create_session do
        post("/api/login")
        summary("Create session")
        description("Return the id of the user if it's found and the password is valid and create a session")
        produces("application/json")
        deprecated(false)
        parameter(:user, :body, Schema.ref(:CreateSessionRequest), "The user details")
        response(200, "Success",Schema.ref(:CreateSessionResponse))
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
        response(code(205), "Session ended")
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
