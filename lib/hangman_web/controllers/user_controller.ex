defmodule HangmanWeb.UserController do

  use HangmanWeb, :controller
  alias Hangman.Accounts
  alias Hangman.Accounts.{User, Credential}
  alias Hangman.Email
  alias Hangman.Repo
  alias Hangman.Token
  import Plug.Conn.Status, only: [code: 1]
  use PhoenixSwagger

  action_fallback HangmanWeb.UserErrorController

  plug :authenticate_api_email_user when action in [:update_password]

  plug :authenticate_api_user when action in [:get_users, :get_user, :create_user, :update_name, :delete_user]

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
      CreateUserRequest:
        swagger_schema do
          title("CreateUserRequest")
          description("POST body for creating a user")
          property(:users, Schema.array(:User), "The user name and email")
          example(%{
              name: "Juan",
              email: "juan@cordage.io"
          })
        end,
      CreateUserResponse:
        swagger_schema do
          title("CreateUserResponse")
          description("Response schema of the user created")
          property(:users, Schema.array(:User), "The user created")
          example(%{
            user: %{
              id: 1,
              name: "Juan",
              lastname: "Rincón",
              email: "juan@cordage.io",
              active: false,
              admin: false
              }
          })
        end,
      CreateUserResponseErrors:
        swagger_schema do
          title("CreateUserResponseErrors")
          description("Response errors from create user")
          example(%{
            name: "can't be blank",
            lastname: "can't be blank",
            credential: %{
              email1: "can't be blank",
              email2: "has invalid format"
            }
          })
        end,
      ShowUsersResponse:
        swagger_schema do
          title("CreateUserResponse")
          description("Response schema of the user created")
          property(:users, Schema.array(:User), "The list of users")
          example(%{
            users: [%{
              id: 1,
              name: "Juan",
              lastname: "Rincón",
              email: "juan@cordage.io",
              active: false,
              admin: false
            }]
          })
        end,
      ShowUsersEmptyResponse:
        swagger_schema do
          title("CreateUserResponse")
          description("Response error users empty")
          example(%{
            error: "There are no users"
            }
          )
        end,
      ShowUserRequest:
        swagger_schema do
          title("ShowUserRequest")
          description("Request params to update a user")
        end,
      ShowUserResponse:
        swagger_schema do
          title("ShowUserResponse")
          description("Response schema of a single user")
          property(:users, Schema.array(:User), "The user found")
          example(%{
            user: %{
              id: 1,
              name: "Juan",
              lastname: "Rincón",
              email: "juan@cordage.io",
              active: false,
              admin: false
              }
          })
        end,
      ShowUserResponseWrongId:
        swagger_schema do
          title("ShowUserErrorResponse")
          description("Response error when id is wrong")
          example(%{
            id: "User not found"
          })
        end,
      UpdateUserNameRequest:
        swagger_schema do
          title("ShowUserResponse")
          description("Reques params to update a name of the user")
          property(:users, Schema.array(:User), "The user name")
          example(%{
              name: "Jose",
              lastname: "Rincón"
          })
        end,
      UpdateUserNameResponse:
        swagger_schema do
          title("ShowUserResponse")
          description("Response schema of a single user")
          property(:users, Schema.array(:User), "The user updated")
          example(%{
            user: %{
              id: 1,
              name: "Jose",
              lastname: "Rincón",
              email: "juan@cordage.io",
              active: false,
              admin: false
              }
          })
        end,
      UpdateUserNameResponseError:
        swagger_schema do
          title("UpdateUserNameResponseError")
          description("Response schema of a single user")
          property(:users, Schema.array(:User), "The user updated")
          example(%{
            id1: "can't be blank",
            id2: "User not found"
          })
        end,
      UpdateUserPasswordRequest:
        swagger_schema do
          title("ShowUserResponse")
          description("Request params to update the password of a user")
          property(:users, Schema.array(:User), "The user password")
          example(%{
              password: "Qwerty2021",
              password_confirmation: "Qwerty2021"
          })
        end,
      UpdateUserPasswordResponse:
        swagger_schema do
          title("ShowUserResponse")
          description("Response schema of a single user")
          property(:users, Schema.array(:User), "The user updated")
          example(%{
            user: %{
              id: 1,
              name: "Jose",
              lastname: "Rincón",
              email: "juan@cordage.io",
              active: true,
              admin: false
              }
          })
        end,
      UpdateUserPasswordResponseError:
        swagger_schema do
          title("UpdateUserPasswordResponseError")
          description("Response schema of a single user")
          property(:users, Schema.array(:User), "The user updated")
          example(%{
            id1: "can't be blank",
            id2: "User not found",
            password1: "can't be blank",
            password2: "has invalid format",
            password_confirmation1: "can't be blank",
            password_confirmation: "does not match confirmation"
          })
        end,
      ResetUserPasswordRequest:
        swagger_schema do
          title("FoundUserRequestByEmail")
          description("Request params to found a user to send email to reset password")
          property(:users, Schema.array(:User), "The user password")
          example(%{
              email: "juan@cordage.io"
          })
        end,
      ResetUserPasswordResponse:
        swagger_schema do
          title("FoundUserResponseByEmail")
          description("Response schema of a single user")
          property(:users, Schema.array(:User), "The user founded")
          example(%{
            user: %{
              id: 1,
              name: "Jose",
              lastname: "Rincón",
              email: "juan@cordage.io",
              active: true,
              admin: false
              }
          })
        end,
      ResetUserPasswordResponseError:
        swagger_schema do
          title("FoundUserResponseByEmail")
          description("Response error of search email")
          example(%{
            email1: "can't be blank",
            email2: "Credential not found"
          })
        end,
      DeleteUserRequest:
        swagger_schema do
          title("DeleteUserRequest")
          description("Request params to delete a user")
        end,
      DeleteUserResponse:
        swagger_schema do
          title("DeleteUserResponse")
          description("Response schema of a single user")
          property(:users, Schema.array(:User), "The user deleted")
          example(%{
            user: %{
              id: 1,
              name: "Juan",
              lastname: "Rincón",
              email: "juan@cordage.io",
              active: false,
              admin: false
              }
          })
        end,
      DeleteUserResponseError:
        swagger_schema do
          title("DeleteUserResponse")
          description("Response schema of a single user")
          property(:users, Schema.array(:User), "The user deleted")
          example(%{
            id1: "can't be blank",
            id2: "User not found"
          })
        end
    }
  end

  swagger_path :get_users do
    get("/manager/users/{np}/{nr}?char={char}")
    summary("All Users")
    description("Return JSON with all users listed in the database")
    parameters do
      authorization :header, :string, "Token to access", required: true
      np :path, :string, "The current page", required: true
      nr :path, :string, "The rows per page", required: true
      char :path, :string, "The user you want to find", required: false
    end
    produces("application/json")
    deprecated(false)
    response(200, "Success",Schema.ref(:ShowUsersResponse))
    response(204, "No users",Schema.ref(:ShowUsersEmptyResponse))
  end
  # coveralls-ignore-stop

  def get_users(conn, params) do
    users = Accounts.list_users(params)
    case users != [] do
      true ->
        count = Accounts.count_users(params)
        conn
        |> put_status(200)
        |> render("users.json", %{count: count, users: users})
      false ->
        conn
        |> put_status(200)
        |> json(%{error: "There are no users"})
    end
  end

  # coveralls-ignore-start
  swagger_path :get_user do
    get("/manager/users/{id}")
    summary("Specific User")
    description("Return JSON with an especific user")
    parameters do
      authorization :header, :string, "Token to access", required: true
      id :path, :string, "The id of the user", required: true
    end
    produces("application/json")
    deprecated(false)
    response(200, "User created OK", Schema.ref(:ShowUserResponse))
    response(404, "Id wrong", Schema.ref(:ShowUserResponseWrongId))
  end
  # coveralls-ignore-stop

  def get_user(conn, params) do
    case Accounts.get_user(params) do
      %User{} = user ->
        conn
        |> put_status(200)
        |> render("user.json", %{user: user})
      %Ecto.Changeset{} = changeset ->
        {:error, changeset}
    end
  end

  # coveralls-ignore-start
  swagger_path :create_user do
    post("/manager/users")
    summary("Add a new user")
    description("Create a new user in the database")
    produces("application/json")
    deprecated(false)
    parameters do
      authorization :header, :string, "Token to access", required: true
      user :body, Schema.ref(:CreateUserRequest), "The user data", required: true
    end
    response(201, "Created", Schema.ref(:CreateUserResponse))
    response(400, "Bad Request", Schema.ref(:CreateUserResponseErrors))
  end
  # coveralls-ignore-stop

  def create_user(conn, params) do
    user_params = %{"name" => params["name"], "lastname" => params["lastname"], "credential" => %{ "email" => params["email"]}}

    case Accounts.create_user(user_params) do
      {:ok, user} ->
        user_params = %{user_id: user.id, email: user.credential.email}
        token = Token.email_sign(user_params)
        Accounts.create_email_token(%{"token" => token})
        Email.user_added_email(user, token)
        conn
        |> put_status(201)
        |> render("user.json", %{user: user})
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  # coveralls-ignore-start
  swagger_path :update_name do
    put("/manager/users/name/{id}")
    summary("Update a user")
    description("Update the user name")
    response(code(205), "Success")
    produces("application/json")
    deprecated(false)
    parameters do
      authorization :header, :string, "Token to access", required: true
      id :path, :string, "The id of the user", required: true
      name :body, Schema.ref(:UpdateUserNameRequest), "The user name", required: true
    end
    response(205, "Updated",Schema.ref(:UpdateUserNameResponse))
    response(400, "Bad Request", Schema.ref(:UpdateUserNameResponseError))
  end
  # coveralls-ignore-stop

  def update_name(conn, params) do
    case Accounts.update_name(params) do
      {:ok, user} ->
        conn
        |> put_status(205)
        |> render("user.json", %{user: user})
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
    end
  end

  # coveralls-ignore-start
  swagger_path :update_password do
    put("/manager/users/pass/{id}")
    summary("Update a user")
    description("Update the user password")
    response(code(205), "Success")
    produces("application/json")
    deprecated(false)
    parameters do
      authorization :header, :string, "Token to access", required: true
      id :path, :string, "The id of the user", required: true
      password :body, Schema.ref(:UpdateUserPasswordRequest), "The user password", required: true
    end
    response(205, "Updated",Schema.ref(:UpdateUserPasswordResponse))
    response(400, "Bad Request", Schema.ref(:UpdateUserPasswordResponseError))
  end
  #coveralls-ignore-stop

  def update_password(conn, params) do
    case Accounts.update_password(params) do
      {:ok, cred} ->
        user = cred.user |> Repo.preload(:credential)
        conn
        |> put_status(205)
        |> render("user.json", %{user: user})
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
    end
  end

  # coveralls-ignore-start
  swagger_path :send_reset_password do
    post("/manager/users/reset/pass")
    summary("Send email reset password")
    description("Search the user on the db and send the reset password email")
    response(code(205), "Success")
    produces("application/json")
    deprecated(false)
    parameters do
      email :body, Schema.ref(:ResetUserPasswordRequest), "The user email", required: true
    end
    response(205, "Updated",Schema.ref(:ResetUserPasswordResponse))
    response(400, "Bad Request",Schema.ref(:ResetUserPasswordResponseError))
  end
  # coveralls-ignore-stop

  def send_reset_password(conn, params) do
   case Accounts.reset_password(params) do
      %Credential{} = cred ->
        user = cred.user |> Repo.preload(:credential)
        user_params = %{user_id: user.id, email: user.credential.email}
        token = Token.email_sign(user_params)
        Accounts.create_email_token(%{"token" => token})
        Email.user_reset_password(user, token)
        conn
        |> put_status(205)
        |> render("user.json", %{user: user})
      %Ecto.Changeset{} = changeset ->
        {:error, changeset}
   end
  end

  # coveralls-ignore-start
  swagger_path :delete_user do
    delete("/manager/users/{id}")
    summary("Specific User")
    description("Return JSON with an especific user")
    parameters do
      authorization :header, :string, "Token to access", required: true
      id :path, :string, "The id of the user", required: true
    end
    produces("application/json")
    deprecated(false)
    response(205, "Deleted",Schema.ref(:DeleteUserResponse))
    response(400, "Bad Request",Schema.ref(:DeleteUserResponseError))
  end
  # coveralls-ignore-stop

  def delete_user(conn, params) do
    case Accounts.delete_user(params) do
      {:ok, user} ->
        conn
        |> put_status(205)
        |> render("user.json", %{user: user})
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end
end
