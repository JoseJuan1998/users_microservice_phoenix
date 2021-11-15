defmodule HangmanWeb.UserController do

  use HangmanWeb, :controller
  alias Hangman.Accounts
  alias Hangman.Accounts.User
  alias Hangman.Email
  alias Hangman.Repo
  import Plug.Conn.Status, only: [code: 1]
  use PhoenixSwagger

  action_fallback HangmanWeb.UserErrorController

  # plug :authenticate_api_user when action in [:get_users, :get_user, :create_user, :update_name, :update_password, :delete_user]

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
              email: "juan@cordage.io",
              active: false
              }
          })
        end,
      ShowUsersResponse:
        swagger_schema do
          title("CreateUserResponse")
          description("Response schema of the user created")
          property(:users, Schema.array(:User), "The list of users")
          example(%{
            user: %{
              id: 1,
              name: "Juan",
              email: "juan@cordage.io",
              active: false
            }
          })
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
              email: "juan@cordage.io",
              active: false
              }
          })
        end,
      UpdateUserNameRequest:
        swagger_schema do
          title("ShowUserResponse")
          description("Reques params to update a name of the user")
          property(:users, Schema.array(:User), "The user name")
          example(%{
              name: "Jose"
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
              email: "juan@cordage.io",
              active: false
              }
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
              email: "juan@cordage.io",
              active: true
              }
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
              email: "juan@cordage.io",
              active: false
              }
          })
        end
    }
  end

  swagger_path :get_users do
    get("/manager/users")
    summary("All Users")
    description("Return JSON with all users listed in the database")
    produces("application/json")
    deprecated(false)
    response(200, "Success",Schema.ref(:ShowUsersResponse))
  end

  def get_users(conn, _) do
    users = Accounts.list_users
    case users != [] do
      true ->
        conn
        |> put_status(200)
        |> render("users.json", %{users: users})
      false ->
        {:error, "There are no users"}
    end
  end

  swagger_path :get_user do
    get("/manager/users/{id}")
    summary("Specific User")
    description("Return JSON with an especific user")
    parameters do
      id :path, :string, "The id of the user", required: true
    end
    produces("application/json")
    deprecated(false)
    response(200, "User created OK",Schema.ref(:ShowUserResponse))
  end

  def get_user(conn, params) do
    case Accounts.get_user(params) do
      %User{} = user->
        conn
        |> put_status(200)
        |> render("user.json", %{user: user})
      %Ecto.Changeset{} = changeset ->
        {:error, changeset}
    end
  end

  swagger_path :create_user do
    post("/manager/users")
    summary("Add a new user")
    description("Create a new user in the database")
    produces("application/json")
    deprecated(false)
    parameters do
      user :body, Schema.ref(:CreateUserRequest), "The user details", required: true
    end
    response(201, "Created",Schema.ref(:CreateUserResponse))
  end

  def create_user(conn, params) do
    user_params = cond do
      not is_nil(params["name"]) and not is_nil(params["email"]) ->
        %{"name" => params["name"],"credential" => %{ "email" => params["email"]}}
      not is_nil(params["name"]) ->
        %{"name" => params["name"],"credential" => %{}}
      not is_nil(params["email"]) ->
        %{"credential" => %{ "email" => params["email"]}}
      true ->
        %{"credential" => %{}}
    end
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        token = Phoenix.Token.sign(HangmanWeb.Endpoint, "auth", user.id)
        Email.user_added_email(user, token)
        conn
        |> put_status(201)
        |> render("user.json", %{user: user})
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  swagger_path :update_name do
    put("/manager/users/name/{id}")
    summary("Update a user")
    description("Update the user name")
    response(code(205), "Success")
    produces("application/json")
    deprecated(false)
    parameters do
      id :path, :string, "The id of the user", required: true
      name :body, Schema.ref(:UpdateUserNameRequest), "The user details", required: true
    end
    response(205, "Updated",Schema.ref(:UpdateUserNameResponse))
  end

  def update_name(conn, params) do
    case Accounts.update_name(params) do
      {:ok, user} ->
        conn
        |> put_status(205)
        |> render("user.json", %{user: user})
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
    end
  end

  swagger_path :update_password do
    put("/manager/users/pass/{id}")
    summary("Update a user")
    description("Update the user password")
    response(code(205), "Success")
    produces("application/json")
    deprecated(false)
    parameters do
      id :path, :string, "The id of the user", required: true
      name :body, Schema.ref(:UpdateUserPasswordRequest), "The user details", required: true
    end
    response(205, "Updated",Schema.ref(:UpdateUserPasswordResponse))
  end

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

  swagger_path :delete_user do
    delete("/manager/users/{id}")
    summary("Specific User")
    description("Return JSON with an especific user")
    parameters do
      id :path, :string, "The id of the user", required: true
    end
    produces("application/json")
    deprecated(false)
    response(205, "Deleted",Schema.ref(:DeleteUserResponse))
  end

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
