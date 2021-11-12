defmodule HangmanWeb.SessionControllerTest do
  use HangmanWeb.ConnCase

  setup_all do: []

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "[POST] /login:" do
    setup do
      connc = build_conn()
      created = connc
      |> post(Routes.user_path(connc, :create_user, %{name: "Juan", email: "juan@example.com"}))
      |> json_response(201)

      connu = build_conn()
      updated = connu
      |> put(Routes.user_path(connu, :update_password, created["user"]["id"], %{password: "Qwerty2021", password_confirmation: "Qwerty2021"}))
      |> json_response(205)

      {:ok, params: updated}
    end

    test "Returns 'information' of the user logged", %{params: params} do
      conn = build_conn()
      response =
        conn
        |> post(Routes.session_path(conn, :create_session, %{email: params["user"]["email"], password: "Qwerty2021"}))
        |> json_response(:ok)

      assert = %{
        "token_auth" => _auth,
        "token_refresh" => _refresh,
        "user_id" => _id
      } = response
    end

    test "Error when 'email' is empty" do
      conn = build_conn()
      response =
        conn
        |> post(Routes.session_path(conn, :create_session, %{password: "Qwerty2021"}))
        |> json_response(400)

      assert = %{
        "error" => _error
      } = response
    end

    test "Error when 'email' is wrong" do
      conn = build_conn()
      response =
        conn
        |> post(Routes.session_path(conn, :create_session, %{email: "juann@example.com", password: "Qwerty2021"}))
        |> json_response(400)

      assert = %{
        "error" => _error
      } = response
    end

    test "Error when 'password' is empty" do
      conn = build_conn()
      response =
        conn
        |> post(Routes.session_path(conn, :create_session, %{email: "juan@example.com"}))
        |> json_response(400)

      assert = %{
        "error" => _error
      } = response
    end

    test "Error when 'password' is wrong" do
      conn = build_conn()
      response =
        conn
        |> post(Routes.session_path(conn, :create_session, %{email: "juan@example.com", password: "Qwerty2020"}))
        |> json_response(400)

      assert = %{
        "error" => _error
      } = response
    end
  end

  describe "ERROR [POST] /login:" do
    setup do
      connc = build_conn()
      created = connc
      |> post(Routes.user_path(connc, :create_user, %{name: "Juan", email: "juan@example.com"}))
      |> json_response(201)

      {:ok, params: created}
    end

    test "Error when user is not active", %{params: params} do
      conn = build_conn()
      response =
        conn
        |> post(Routes.session_path(conn, :create_session, %{email: params["user"]["email"], password: "Qwerty2021"}))
        |> json_response(400)

      assert = %{
        "error" => _error
      } = response
    end
  end

  describe "[DELETE] /logout:" do
    test "Redirect to login" do
      conn = build_conn()
      response =
        conn
        |> delete(Routes.session_path(conn, :delete_session))
        |> html_response(205)

        assert = "<html><body>You are being <a href=\"https://www.google.com\">redirected</a>.</body></html>" = response
    end
  end

end
