defmodule HangmanWeb.UserControllerTest do
  use HangmanWeb.ConnCase
  alias Hangman.Token
  alias HangmanWeb.Auth.Guardian
  alias Hangman.Repo
  alias Hangman.Accounts

  setup_all do: []

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "[ANY] not headder token" do
    test "Error when 'token' does not exist or it is invalid or expired" do
      conn = build_conn()

      conn
      |> get(Routes.user_path(conn, :get_users))
      |> response(401)
    end

    test "Error when 'token' does not exist or it is invalid or expired password" do
      conn = build_conn()

      conn
      |> put(Routes.user_path(conn, :update_password))
      |> response(401)
    end
  end

  describe "[GET] /users/:np/:nr:" do

    setup do
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", lastname: "Alcantara", email: "juan@mail.com", id: 1}, "juan@mail.com")
      conn = build_conn()
      conn
      |> put_req_header("authorization", "Bearer "<>token)
      |> post(Routes.user_path(conn, :create_user, %{name: "Juan", lastname: "Rincón", email: "juan@example.com"}))
      |> json_response(201)
    end

    test "Returns a list of users" do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", lastname: "Alcantara", email: "juan@mail.com", id: 1}, "juan@mail.com")
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> get(Routes.user_path(conn, :get_users, 1, 5))
        |> json_response(:ok)

      assert %{
        "users" => [%{
          "active" => _active,
          "admin" => _admin,
          "email" => _email,
          "id" => _id,
          "name" => _name,
          "lastname" => _lastname
        }]
        } = response
    end

    test "Returns a list of users matched" do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", lastname: "Alcantara", email: "juan@mail.com", id: 1}, "juan@mail.com")
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> get(Routes.user_path(conn, :get_users, 1, 5, %{char: "a"}))
        |> json_response(:ok)

      assert %{
        "users" => [%{
          "active" => _active,
          "admin" => _admin,
          "email" => _email,
          "id" => _id,
          "name" => _name,
          "lastname" => _lastname
        }]
        } = response
    end
  end

  describe "ERROR [GET] /users:" do

    test "Error when 'users' is empty" do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", lastname: "Alcantara", email: "juan@mail.com", id: 1}, "juan@mail.com")
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> get(Routes.user_path(conn, :get_users))
        |> json_response(200)

      assert %{
        "error" => _error
       } = response
    end
  end

  describe "[GET] /users/:id:" do

    setup do
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", lastname: "Alcantara", email: "juan@mail.com", id: 1}, "juan@mail.com")
      conn = build_conn()
      params = conn
      |> put_req_header("authorization", "Bearer "<>token)
      |> post(Routes.user_path(conn, :create_user, %{name: "Juan", lastname: "Rincón", email: "juan@example.com"}))
      |> json_response(201)
      {:ok, params: params}
    end

    test "Returns one user", %{params: params} do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", lastname: "Alcantara", email: "juan@mail.com", id: 1}, "juan@mail.com")
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> get(Routes.user_path(conn, :get_user, params["user"]["id"]))
        |> json_response(:ok)

      assert %{
        "user" => %{
          "active" => _active,
          "admin" => _admin,
          "email" => _email,
          "id" => _id,
          "name" => _name,
          "lastname" => _lastname
        }
        } = response
    end
  end

  describe "ERROR [GET] /users/:id:" do

    test "Error when 'id' is wrong" do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", lastname: "Alcantara", email: "juan@mail.com", id: 1}, "juan@mail.com")
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> get(Routes.user_path(conn, :get_user, 0))
        |> json_response(404)

      assert %{
        "id" => _id
        } = response
    end
  end


  describe "[POST] /users:" do

    test "Returns the user created" do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", lastname: "Alcantara", email: "juan@mail.com", id: 1}, "juan@mail.com")
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> post(Routes.user_path(conn, :create_user, %{name: "Juan", lastname: "Rincón", email: "juan@example.com"}))
        |> json_response(201)

      assert %{
        "user" => %{
          "active" => _active,
          "admin" => _admin,
          "email" => _email,
          "id" => _id,
          "name" => _name,
          "lastname" => _lastname
        }
        } = response
    end

    test "Error when 'name' is empty" do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", lastname: "Alcantara", email: "juan@mail.com", id: 1}, "juan@mail.com")
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> post(Routes.user_path(conn, :create_user, %{lastname: "Rincón", email: "juan@example.com"}))
        |> json_response(400)

      assert %{
        "name" => _name
        } = response
    end

    test "Error when 'lastname' is empty" do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", lastname: "Alcantara", email: "juan@mail.com", id: 1}, "juan@mail.com")
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> post(Routes.user_path(conn, :create_user, %{name: "Juan", email: "juan@example.com"}))
        |> json_response(400)

      assert %{
        "lastname" => _lastname
        } = response
    end

    test "Error when 'email' is empty" do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", lastname: "Alcantara", email: "juan@mail.com", id: 1}, "juan@mail.com")
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> post(Routes.user_path(conn, :create_user, %{name: "Juan", lastname: "Rincón"}))
        |> json_response(400)

      assert %{
        "credential" => %{
         "email" => _email
        }
      } = response
    end

    test "Error when 'email' is invalid format" do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", lastname: "Alcantara", email: "juan@mail.com", id: 1}, "juan@mail.com")
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> post(Routes.user_path(conn, :create_user, %{name: "Juan", lastname: "Rincón", email: "juanexample.com"}))
        |> json_response(400)

      assert %{
        "credential" => %{
          "email" => _email
        }
      } = response
    end

    test "Error when 'params' are empty" do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", lastname: "Alcantara", email: "juan@mail.com", id: 1}, "juan@mail.com")
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> post(Routes.user_path(conn, :create_user, %{}))
        |> json_response(400)

      assert %{
        "credential" => %{
          "email" => _email
         },
        "name" => _name,
        "lastname" => _lastname
        } = response
    end
  end

  describe "[PUT] /users/[name, password]/:id:" do
    setup do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", lastname: "Alcantara", email: "juan@mail.com", id: 1}, "juan@mail.com")
      params = conn
      |> put_req_header("authorization", "Bearer "<>token)
      |> post(Routes.user_path(conn, :create_user, %{name: "Juan", lastname: "Rincón", email: "juan@example.com"}))
      |> json_response(201)
      {:ok, params: params}
    end

    test "Returns the user name updated", %{params: params} do

      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", lastname: "Alcantara", email: "juan@mail.com", id: 1}, "juan@mail.com")
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> put(Routes.user_path(conn, :update_name, params["user"]["id"], %{name: "Juan"}))
        |> json_response(205)

      assert %{
        "user" => %{
          "active" => _active,
          "admin" => _admin,
          "email" => _email,
          "id" => _id,
          "name" => _name,
          "lastname" => _lastname
        }
        } = response
    end

    test "Returns the user lastname updated", %{params: params} do

      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", lastname: "Alcantara", email: "juan@mail.com", id: 1}, "juan@mail.com")
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> put(Routes.user_path(conn, :update_name, params["user"]["id"], %{lastname: " Rincón"}))
        |> json_response(205)

      assert %{
        "user" => %{
          "active" => _active,
          "admin" => _admin,
          "email" => _email,
          "id" => _id,
          "name" => _name,
          "lastname" => _lastname
        }
        } = response
    end

    test "Error when 'params' is empty for name" do

      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", lastname: "Alcantara", email: "juan@mail.com", id: 1}, "juan@mail.com")
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> put(Routes.user_path(conn, :update_name))
        |> json_response(404)

      assert %{
        "id" => _id,
        "name" => _name
        } = response
    end

    test "Error when 'id' is empty for name" do

      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", lastname: "Alcantara", email: "juan@mail.com", id: 1}, "juan@mail.com")
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> put(Routes.user_path(conn, :update_name, :id, %{name: "Juan"}))
        |> json_response(404)

      assert %{
        "id" => _id
        } = response
    end

    test "Error when 'id' is wrong for name" do

      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", lastname: "Alcantara", email: "juan@mail.com", id: 1}, "juan@mail.com")
      conn = build_conn()
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> put(Routes.user_path(conn, :update_name, 0, %{name: "Juan"}))
        |> json_response(404)

      assert %{
        "id" => _id
        } = response
    end

    test "Returns the user password updated", %{params: params} do

      %{token: token_email} = List.first(Repo.all(Accounts.EmailToken))
      conn = build_conn()
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token_email)
        |> put(Routes.user_path(conn, :update_password, params["user"]["id"], %{password: "Qwerty2021", password_confirmation: "Qwerty2021"}))
        |> json_response(205)

      assert %{
        "user" => %{
          "active" => _active,
          "admin" => _admin,
          "email" => _email,
          "id" => _id,
          "name" => _name,
          "lastname" => _lastname
        }
        } = response
    end

    test "Error Token invalid update password", %{params: params} do

      {:ok, token, _} = Guardian.test_token_email(%{name: "Juan", lastname: "Alcantara", email: "juan@mail.com", id: 1})
      conn = build_conn()
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> put(Routes.user_path(conn, :update_password, params["user"]["id"], %{password: "Qwerty2021", password_confirmation: "Qwerty2021"}))
        |> json_response(401)
    end

    test "Error when 'id' is empty for password" do

      conn = build_conn()
      %{token: token} = List.first(Repo.all(Accounts.EmailToken))
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> put(Routes.user_path(conn, :update_password, :id, %{password: "Qwerty", password_confirmation: "Qwerty2021"}))
        |> json_response(404)

      assert %{
        "id" => _id
        } = response
    end

    test "Error when 'id' is wrong for password" do

      conn = build_conn()
      %{token: token} = List.first(Repo.all(Accounts.EmailToken))
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> put(Routes.user_path(conn, :update_password, 0, %{password: "Qwerty", password_confirmation: "Qwerty2021"}))
        |> json_response(404)

      assert %{
        "id" => _id
        } = response
    end

    test "Error when 'password' is empty", %{params: params} do

      conn = build_conn()
      %{token: token} = List.first(Repo.all(Accounts.EmailToken))
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> put(Routes.user_path(conn, :update_password, params["user"]["id"], %{password_confirmation: "Qwerty2021"}))
        |> json_response(400)

      assert %{
        "password" => _password,
        "password_confirmation" => _password_confirmation
      } = response
    end

    test "Error when 'password_confirmation' is empty", %{params: params} do

      conn = build_conn()
      %{token: token} = List.first(Repo.all(Accounts.EmailToken))
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> put(Routes.user_path(conn, :update_password, params["user"]["id"], %{password: "Qwerty2021"}))
        |> json_response(400)

      assert %{
        "password_confirmation" => _password_confirmation
      } = response
    end

    test "Error when 'password' is invalid format", %{params: params} do

      conn = build_conn()
      %{token: token} = List.first(Repo.all(Accounts.EmailToken))
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> put(Routes.user_path(conn, :update_password, params["user"]["id"], %{password: "qwerty2021", password_confirmation: "Qwerty2021"}))
        |> json_response(400)

      assert %{
        "password" => _password,
        "password_confirmation" => _password_confirmation
      } = response
    end

    test "Error when 'password_confirmation' does not match", %{params: params} do

      conn = build_conn()
      %{token: token} = List.first(Repo.all(Accounts.EmailToken))
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> put(Routes.user_path(conn, :update_password, params["user"]["id"], %{password: "Qwerty2021", password_confirmation: "qwerty2021"}))
        |> json_response(400)

      assert %{
        "password_confirmation" => _password_confirmation
      } = response
    end
  end

  describe "[POST] /users/reset/pass:" do
    setup do
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", lastname: "Alcantara", email: "juan@mail.com", id: 1}, "juan@mail.com")
      conn = build_conn()
      params = conn
      |> put_req_header("authorization", "Bearer "<>token)
      |> post(Routes.user_path(conn, :create_user, %{name: "Juan", lastname: "Rincón", email: "juan@example.com"}))
      |> json_response(201)
      {:ok, params: params}
    end

    test "Returns the user found in the database, and send the email to reset the password" do
      conn = build_conn()

      response =
        conn
        |> post(Routes.user_path(conn, :send_reset_password, %{email: "juan@example.com"}))
        |> json_response(205)

      assert %{
        "user" => %{
          "active" => _active,
          "email" => _email,
          "id" => _id,
          "name" => _name
        }
      } = response
    end

    test "Error when 'email' is empty" do
      conn = build_conn()

      response =
        conn
        |> post(Routes.user_path(conn, :send_reset_password))
        |> json_response(400)

      assert %{
        "email" => _error
      } = response
    end

    test "Error when 'email' is wrong" do
      conn = build_conn()

      response =
        conn
        |> post(Routes.user_path(conn, :send_reset_password, %{email: "password@example.com"}))
        |> json_response(400)

      assert %{
        "email" => _error
      } = response
    end
  end

  describe "[DELETE] /users/:id:" do
    setup do
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", lastname: "Alcantara", email: "juan@mail.com", id: 1}, "juan@mail.com")
      conn = build_conn()
      params = conn
      |> put_req_header("authorization", "Bearer "<>token)
      |> post(Routes.user_path(conn, :create_user, %{name: "Juan", lastname: "Rincón", email: "juan@example.com"}))
      |> json_response(201)
      {:ok, params: params}
    end

    test "Returns the user deleted", %{params: params} do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", lastname: "Alcantara", email: "juan@mail.com", id: 1}, "juan@mail.com")
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> delete(Routes.user_path(conn, :delete_user, params["user"]["id"]))
        |> json_response(205)

      assert %{
        "user" => %{
          "active" => _active,
          "admin" => _admin,
          "email" => _email,
          "id" => _id,
          "name" => _name,
          "lastname" => _lastname
        }
        } = response
    end

    test "Error when 'id' is empty" do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", lastname: "Alcantara", email: "juan@mail.com", id: 1}, "juan@mail.com")
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> delete(Routes.user_path(conn, :delete_user))
        |> json_response(404)

      assert %{
        "id" => _id
       } = response
    end

    test "Error when 'id' is wrong" do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", lastname: "Alcantara", email: "juan@mail.com", id: 1}, "juan@mail.com")
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> delete(Routes.user_path(conn, :delete_user, 0))
        |> json_response(404)

      assert %{
        "id" => _id
        } = response
    end
  end
end
