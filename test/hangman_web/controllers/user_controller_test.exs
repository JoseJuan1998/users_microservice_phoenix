defmodule HangmanWeb.UserControllerTest do
  use HangmanWeb.ConnCase

  setup_all do: []

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "[GET] /users:" do

    setup do
      conn = build_conn()
      response = conn
      |> post(Routes.user_path(conn, :create_user, %{name: "Juan", email: "juan@example.com"}))
      |> json_response(201)
    end

    test "Returns a list of users" do
      conn = build_conn()
      response =
        conn
        |> get(Routes.user_path(conn, :get_users))
        |> json_response(:ok)

      assert %{
        "users" => [%{
          "active" => _active,
          "email" => _email,
          "id" => _id,
          "name" => _name
        }]
        } = response
    end
  end

  describe "ERROR [GET] /users:" do

    test "Error when 'users' is empty" do
      conn = build_conn()
      response =
        conn
        |> get(Routes.user_path(conn, :get_users))
        |> json_response(400)

      assert %{
        "error" => _error
       } = response
    end
  end

  describe "[GET] /users/:id:" do

    setup do
      conn = build_conn()
      params = conn
      |> post(Routes.user_path(conn, :create_user, %{name: "Juan", email: "juan@example.com"}))
      |> json_response(201)
      {:ok, params: params}
    end

    test "Returns one user", %{params: params} do
      conn = build_conn()
      response =
        conn
        |> get(Routes.user_path(conn, :get_user, params["user"]["id"]))
        |> json_response(:ok)

      assert %{
        "user" => %{
          "active" => _active,
          "email" => _email,
          "id" => _id,
          "name" => _name
        }
        } = response
    end
  end

  describe "ERROR [GET] /users/:id:" do

    test "Error when 'id' is wrong" do
      conn = build_conn()
      response =
        conn
        |> get(Routes.user_path(conn, :get_user, 0))
        |> json_response(400)

      assert %{
        "id" => _error
        } = response
    end
  end


  describe "[POST] /users:" do

    test "Returns the user created" do
      conn = build_conn()
      response =
        conn
        |> post(Routes.user_path(conn, :create_user, %{name: "Juan", email: "juan@example.com"}))
        |> json_response(201)

      assert %{
        "user" => %{
          "active" => _active,
          "email" => _email,
          "id" => _id,
          "name" => _name
        }
        } = response
    end

    test "Error when 'name' is empty" do
      conn = build_conn()
      response =
        conn
        |> post(Routes.user_path(conn, :create_user, %{email: "juan@example.com"}))
        |> json_response(400)

      assert %{
        "name" => _error
        } = response
    end

    test "Error when 'email' is empty" do
      conn = build_conn()
      response =
        conn
        |> post(Routes.user_path(conn, :create_user, %{name: "Juan"}))
        |> json_response(400)

      assert %{
        "email" => _error
        } = response
    end

    test "Error when 'email' is invalid format" do
      conn = build_conn()
      response =
        conn
        |> post(Routes.user_path(conn, :create_user, %{name: "Juan", email: "juanexample.com"}))
        |> json_response(400)

      assert %{
        "email" => _error
        } = response
    end

    test "Error when 'params' are empty" do
      conn = build_conn()
      response =
        conn
        |> post(Routes.user_path(conn, :create_user, %{}))
        |> json_response(400)

      assert %{
        "email" => _error,
        "name" => _error
        } = response
    end
  end

  describe "[PUT] /users/[name, password]/:id:" do
    setup do
      conn = build_conn()
      params = conn
      |> post(Routes.user_path(conn, :create_user, %{name: "Juan", email: "juan@example.com"}))
      |> json_response(201)
      {:ok, params: params}
    end

    test "Returns the user name updated", %{params: params} do

      conn = build_conn()
      response =
        conn
        |> put(Routes.user_path(conn, :update_name, params["user"]["id"], %{name: "Juan"}))
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

    test "Error when 'params' is empty for name" do

      conn = build_conn()
      response =
        conn
        |> put(Routes.user_path(conn, :update_name))
        |> json_response(400)

      assert %{
        "id" => _error,
        "name" => _error
        } = response
    end

    test "Error when 'id' is empty for name" do

      conn = build_conn()
      response =
        conn
        |> put(Routes.user_path(conn, :update_name, :id, %{name: "Juan"}))
        |> json_response(400)

      assert %{
        "id" => _error
        } = response
    end

    test "Error when 'id' is wrong for name" do

      conn = build_conn()
      response =
        conn
        |> put(Routes.user_path(conn, :update_name, 0, %{name: "Juan"}))
        |> json_response(400)

      assert %{
        "id" => _error
        } = response
    end

    test "Returns the user password updated", %{params: params} do

      conn = build_conn()
      response =
        conn
        |> put(Routes.user_path(conn, :update_password, params["user"]["id"], %{password: "Qwerty2021", password_confirmation: "Qwerty2021"}))
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

    test "Error when 'id' is empty for password" do

      conn = build_conn()
      response =
        conn
        |> put(Routes.user_path(conn, :update_password, :id, %{password: "Qwerty", password_confirmation: "Qwerty2021"}))
        |> json_response(400)

      assert %{
        "id" => _error
        } = response
    end

    test "Error when 'id' is wrong for password" do

      conn = build_conn()
      response =
        conn
        |> put(Routes.user_path(conn, :update_password, 0, %{password: "Qwerty", password_confirmation: "Qwerty2021"}))
        |> json_response(400)

      assert %{
        "id" => _error
        } = response
    end

    test "Error when 'password' is empty", %{params: params} do

      conn = build_conn()
      response =
        conn
        |> put(Routes.user_path(conn, :update_password, params["user"]["id"], %{password_confirmation: "Qwerty2021"}))
        |> json_response(400)

      assert %{
        "password" => _error,
        "password_confirmation" => _match
      } = response
    end

    test "Error when 'password_confirmation' is empty", %{params: params} do

      conn = build_conn()
      response =
        conn
        |> put(Routes.user_path(conn, :update_password, params["user"]["id"], %{password: "Qwerty2021"}))
        |> json_response(400)

      assert %{
        "password_confirmation" => _error
      } = response
    end

    test "Error when 'password' is invalid format", %{params: params} do

      conn = build_conn()
      response =
        conn
        |> put(Routes.user_path(conn, :update_password, params["user"]["id"], %{password: "qwerty2021", password_confirmation: "Qwerty2021"}))
        |> json_response(400)

      assert %{
        "password" => _error,
        "password_confirmation" => _match
      } = response
    end

    test "Error when 'password_confirmation' does not match", %{params: params} do

      conn = build_conn()
      response =
        conn
        |> put(Routes.user_path(conn, :update_password, params["user"]["id"], %{password: "Qwerty2021", password_confirmation: "qwerty2021"}))
        |> json_response(400)

      assert %{
        "password_confirmation" => _match
      } = response
    end
  end

  describe "[DELETE] /users/:id:" do
    setup do
      conn = build_conn()
      params = conn
      |> post(Routes.user_path(conn, :create_user, %{name: "Juan", email: "juan@example.com"}))
      |> json_response(201)
      {:ok, params: params}
    end

    test "Returns the user deleted", %{params: params} do
      conn = build_conn()
      response =
        conn
        |> delete(Routes.user_path(conn, :delete_user, params["user"]["id"]))
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

    test "Error when 'id' is empty" do
      conn = build_conn()
      response =
        conn
        |> delete(Routes.user_path(conn, :delete_user, :id))
        |> json_response(400)

      assert %{
        "id" => _error
       } = response
    end

    test "Error when 'id' is wrong" do
      conn = build_conn()
      response =
        conn
        |> delete(Routes.user_path(conn, :delete_user, 0))
        |> json_response(400)

      assert %{
        "id" => _error
        } = response
    end
  end
end
