defmodule HangmanWeb.UserController do

  use HangmanWeb, :controller
  alias Hangman.Accounts
  alias Hangman.Accounts.User
  alias Hangman.{Mailer, Email}
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
      CreateUserRequest:
        swagger_schema do
          title("CreateUserRequest")
          description("POST body for creating a user")
          property(:users, Schema.array(:User), "The users details")
          example(%{
              name: "Juan",
              credential: %{
                email: "juan@cordage.io",
                admin: true,
                active: false
              }
          })
        end,
      CreateUserResponse:
        swagger_schema do
          title("CreateUserResponse")
          description("Response schema of the user created")
          property(:users, Schema.array(:User), "The users details")
          example(%{
            user: %{
              name: "Juan",
              email: "juan@cordage.io",
              admin: true,
              active: false
              }
          })
        end,
      ShowUsersResponse:
        swagger_schema do
          title("CreateUserResponse")
          description("Response schema of the user created")
          property(:users, Schema.array(:User), "The users details")
          example(%{
            user: %{
              name: "Juan",
              email: "juan@cordage.io",
              admin: true,
              active: false
            }
          })
        end,
      ShowUserRequest:
        swagger_schema do
          title("ShowUserRequest")
          description("Response schema of the user created")
          property(:id, Schema.array(:User), "The users details")
        end,
      ShowUserResponse:
        swagger_schema do
          title("ShowUserResponse")
          description("Response schema of a single user")
          property(:users, Schema.array(:User), "The users details")
          example(%{
            user: %{
              name: "Juan",
              email: "juan@cordage.io",
              admin: true,
              active: false
              }
          })
        end,
      UpdateUserRequest:
        swagger_schema do
          title("ShowUserResponse")
          description("Response schema of a single user")
          property(:users, Schema.array(:User), "The users details")
          example(%{
              name: "Juan",
              credential: %{
                admin: true,
                active: false,
                password: "Qwerty2021",
                password_confirmation: "Qwerty2021"
              }
          })
        end,
      UpdateUserResponse:
        swagger_schema do
          title("ShowUserResponse")
          description("Response schema of a single user")
          property(:users, Schema.array(:User), "The users details")
          example(%{
            user: %{
              name: "Juan",
              email: "juan@cordage.io",
              admin: true,
              active: false
              }
          })
        end
    }
  end

  swagger_path :get_users do
    get("/api/users")
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
    get("/api/users/:id")
    summary("Specific User")
    description("Return JSON with an especific user")
    produces("application/json")
    deprecated(false)
    response(200, "User created OK",Schema.ref(:ShowUserResponse))
  end

  def get_user(conn, %{"id" => id}) do
    case Accounts.get_user(id) do
      nil ->
        {:error, "User not found"}
      user ->
        conn
        |> put_status(200)
        |> render("user.json", %{user: user})
    end
  end

  swagger_path :create_user do
    post("/api/users")
    summary("Add a new user")
    description("Create a new user in the database")
    produces("application/json")
    deprecated(false)
    parameter(:user, :body, Schema.ref(:CreateUserRequest), "The user details")
    response(201, "Created",Schema.ref(:CreateUserResponse))
  end

  def create_user(conn, user_params) do
    user = %User{}
    changeset = cond do
      user_params["credential"] != nil ->
        Accounts.change_user(user, user_params)
      user_params["name"] != nil ->
        Accounts.change_user(user, %{"name" => user_params["name"],"credential" => %{}})
      true ->
        Accounts.change_user(user, %{"credential" => %{}})
    end
    case changeset.valid? do
      true ->
        case Accounts.create_user(user_params) do
          {:ok, user} ->
            Email.user_added_email(user)
            conn
            |> put_status(201)
            |> render("user.json", %{user: user})
          {:error, error} ->
            {:error, error}
        end
      false ->
        {:error, changeset}
    end
  end

  swagger_path :update_user do
    put("/api/users/:id")
    summary("Update a user")
    description("Update the user information")
    response(code(205), "Success")
    produces("application/json")
    deprecated(false)
    parameter(:user, :body, Schema.ref(:UpdateUserRequest), "The user details")
    response(205, "Updated",Schema.ref(:UpdateUserResponse))
  end

  def update_user(conn, params) do

    user = if params["id"] != nil do
      Accounts.get_user(params["id"])
    else
      nil
    end
    case user do
      nil ->
        {:error, "User not found"}
      user ->
        new_params = cond do
          params["credential"] != nil && params["name"] != nil ->
            %{"name" => params["name"], "credential" => Map.put(params["credential"], "id", params["id"])}
          params["name"] != nil ->
            %{"name" => params["name"]}
          params["credential"] != nil ->
            %{"credential" => Map.put(params["credential"], "id", params["id"])}
          true ->
            %{}
        end

        case Accounts.update_user(user, new_params) do
          {:ok, user} ->
            conn
            |> put_status(205)
            |> render("user.json", %{user: user})
          {:error, %Ecto.Changeset{} = changeset} ->
            {:error, changeset}
          {:error, error} ->
            {:error, error}
          true ->
            {:error, "Can't update"}
        end
    end
  end

  swagger_path :delete_user do
    delete("/api/users/:id")
    summary("Delte a User")
    description("Return JSON with an especific user that was deleted")
    response(code(205), "Success")
    produces("application/json")
    deprecated(false)
  end

  def delete_user(conn, params) do
    user = if params["id"] != nil do
      Accounts.get_user(params["id"])
    else
      nil
    end
    case user do
      nil ->
        {:error, "User not found"}
      user ->
        case Accounts.delete_user(user) do
          {:ok, user} ->
            conn
            |> put_status(205)
            |> render("user.json", %{user: user})
          {:error, %Ecto.Changeset{} = changeset} ->
            {:error, changeset}
        end
    end
  end
end
