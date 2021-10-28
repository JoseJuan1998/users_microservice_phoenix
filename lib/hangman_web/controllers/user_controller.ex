defmodule HangmanWeb.UserController do

  use HangmanWeb, :controller
  alias Hangman.Accounts
  alias Hangman.Accounts.User
  import Plug.Conn.Status, only: [code: 1]
  use PhoenixSwagger

  action_fallback HangmanWeb.UserErrorController
  swagger_path :get_users do
    get("/users")
    summary("All Users")
    description("Return JSON with all users listed in the database")
    response(code(:ok), "Success")
    produces("application/json")
    deprecated(false)
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
    get("/users/:id")
    summary("Specific User")
    description("Return JSON with an especific user")
    response(code(:ok), "Success")
    produces("application/json")
    deprecated(false)
  end

  def get_user(conn, %{"id" => id}) do
    case Accounts.get_user!(id) do
      nil ->
        {:error, "User not found"}
      user ->
        conn
        |> put_status(200)
        |> render("user.json", %{user: user})
    end
  end

  swagger_path :create_user do
    post("/users")
    summary("Add a new user")
    description("Create a new user in the database")
    response(code(201), "Created")
    produces("application/json")
    deprecated(false)
  end

  def create_user(conn, user_params) do
    user = %User{}
    changeset = Accounts.change_user(user, user_params)
    case changeset.valid? do
      true ->
        {:ok, user} = Accounts.create_user(user_params)
        conn
        |> put_status(201)
        |> render("user.json", %{user: user})
      false ->
        {:error, changeset}
    end
  end

  swagger_path :update_user do
    put("/users/:id")
    summary("Update a user")
    description("Update the user information")
    response(code(205), "Success")
    produces("application/json")
    deprecated(false)
  end

  def update_user(conn, %{"id" => id, "name" => name, "credential" => credential}) do
    user = Accounts.get_user!(id)
    params = %{name: name, credential: Map.put(credential, "id", id)}
    case Accounts.update_user(user, params) do
      {:ok, user} ->
        conn
        |> put_status(205)
        |> render("user.json", %{user: user})
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  swagger_path :delete_user do
    delete("/users/:id")
    summary("Delte a User")
    description("Return JSON with an especific user that was deleted")
    response(code(205), "Success")
    produces("application/json")
    deprecated(false)
  end

  def delete_user(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
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
