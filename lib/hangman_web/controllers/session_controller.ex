defmodule HangmanWeb.SessionController do
  use HangmanWeb, :controller
  alias Hangman.Accounts
  alias Hangman.Repo
  alias Hangman.Token
  alias HangmanWeb.Auth.Guardian
  import Plug.Conn.Status, only: [code: 1]
  use PhoenixSwagger

  action_fallback HangmanWeb.UserErrorController

  # coveralls-ignore-start
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
          token_auth: "SFMyNTY.g2gDYQduBgA01y8LfQFiAAFRgA.5IuDTyU07BU1DdTfVLPv5aDydsg7tdRNMhC33cL__NA",
          token_refresh: "SFMyNTY.g2gDYQduBgA01y8LfQFiAAFRgA.9mGWauIJ7RdO86yfQ_m9wvXefmb5kEy8yiI57yOOz5o",
          user_id: 1
        })
        end,
      CreateSessionResponseError:
        swagger_schema do
        title("CreateSessionResponse")
        description("Response and id")
        property(:users, Schema.array(:User), "The users details")
        example(%{
          error1: "user not found",
          error2: "wrong password",
          error3: "inactive account",
          error4: "email can't be blank",
          error5: "password can't be blank"
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
      response(400, "Bad Request",Schema.ref(:CreateSessionResponseError))
  end
  # coveralls-ignore-stop

  def create_session(conn, params) do
      with {:ok, token, user}  <- HangmanWeb.Auth.Guardian.authenticate(params["email"], params["password"]) do
        conn
        |> put_status(:ok)
        |> render("session.json", %{user: user |> Repo.preload(:credential), token: token})
      end
  end

  # coveralls-ignore-start
  swagger_path :delete_session do
      delete("/manager/logout")
      summary("Delete session")
      description("Delete the session")
      response(code(205), "Session ended")
      produces("application/json")
      deprecated(false)
  end
  # coveralls-ignore-stop

  def delete_session(conn, _) do
      conn
      |> put_status(205)
      |> assign(:current_user, nil)
      |> redirect(external: "http://hangmangame1.eastus.cloudapp.azure.com/login")
  end
end
