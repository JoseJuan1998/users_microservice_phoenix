defmodule HangmanWeb.SessionController do
  use HangmanWeb, :controller
  alias Hangman.Accounts
  alias Hangman.Token
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
      post("/manager/login")
      summary("Create session")
      description("Return the id of the user if it's found and the password is valid and create a session")
      produces("application/json")
      deprecated(false)
      parameter(:user, :body, Schema.ref(:CreateSessionRequest), "The user details")
      response(200, "Success",Schema.ref(:CreateSessionResponse))
  end

  def create_session(conn, params) do
      cond do
        not is_nil(params["email"]) && not is_nil(params["password"]) ->
          case Accounts.authenticate_by_email_password(params["email"], params["password"]) do
            {:ok, user} ->
              conn
              |> put_status(200)
              |> assign(:current_user, user.id)
              |> render("session.json", %{user_id: user.id, token_auth: Token.auth_sign(user.id), token_refresh: Token.refresh_sign(user.id)})
            {:error, :unauthorized} ->
              {:error, "Wrong password"}
            {:error, :not_found} ->
              {:error, "User not found"}
            {:error, :not_active} ->
              {:error, "Verify your email, check your mailbox"}
            {:error, :not_password} ->
              {:error, "Create a password"}
            true ->
              {:error, "Unknown error"}
          end
        true ->
          {:error, "No params received"}
      end
  end

  swagger_path :delete_session do
      delete("/manager/logout")
      summary("Delete session")
      description("Delete the session")
      response(code(205), "Session ended")
      produces("application/json")
      deprecated(false)
  end

  def delete_session(conn, _) do
      conn
      |> put_status(205)
      |> assign(:current_user, nil)
      |> redirect(external: "https://www.google.com")
  end
end
