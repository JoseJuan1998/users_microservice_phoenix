defmodule HangmanWeb.SessionControllerTest do
  use HangmanWeb.ConnCase
  alias Hangman.Token
  alias HangmanWeb.Auth.Guardian
  alias Hangman.Repo
  alias Hangman.Accounts

  setup_all do: []

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "[POST] /login:" do
    setup do
      {:ok, token_auth, _} = Guardian.test_token_auth(%{name: "Juan", lastname: "Alcantara", email: "juan@mail.com", id: 1})
      connc = build_conn()
      created = connc
      |> put_req_header("authorization", "Bearer "<>token_auth)
      |> post(Routes.user_path(connc, :create_user, %{name: "Juan", lastname: "Rincón", email: "juan@example.com"}))
      |> json_response(201)

      %{token: token_email} = List.first(Repo.all(Accounts.EmailToken))
      connu = build_conn()
      updated = connu
      |> put_req_header("authorization", "Bearer "<>token_email)
      |> put(Routes.user_path(connu, :update_password, created["user"]["id"], %{password: "Qwerty2021", password_confirmation: "Qwerty2021"}))
      |> json_response(205)
    end

    test "Returns 'information' of the user logged" do
      conn = build_conn()
      response =
        conn
        |> post(Routes.session_path(conn, :create_session, %{email: "juan@example.com", password: "Qwerty2021"}))
        |> json_response(:ok)

      assert %{
        "token" => _auth,
        "user" => _id
      } = response
    end

    test "Error when 'email' is empty" do
      conn = build_conn()
      response =
        conn
        |> post(Routes.session_path(conn, :create_session, %{password: "Qwerty2021"}))
        |> json_response(400)

      assert %{
        "error" => _error
      } = response
    end

    test "Error when 'email' is wrong" do
      conn = build_conn()
      response =
        conn
        |> post(Routes.session_path(conn, :create_session, %{email: "juann@example.com", password: "Qwerty2021"}))
        |> json_response(400)

      assert %{
        "error" => _error
      } = response
    end

    test "Error when 'password' is empty" do
      conn = build_conn()
      response =
        conn
        |> post(Routes.session_path(conn, :create_session, %{email: "juan@example.com"}))
        |> json_response(400)

      assert %{
        "error" => _error
      } = response
    end

    test "Error when 'password' is wrong" do
      conn = build_conn()
      response =
        conn
        |> post(Routes.session_path(conn, :create_session, %{email: "juan@example.com", password: "Qwerty2020"}))
        |> json_response(400)

      assert %{
        "error" => _error
      } = response
    end
  end

  describe "ERROR [POST] /login:" do
    setup do
      connc = build_conn()
      {:ok, token_auth, _} = Guardian.test_token_auth(%{name: "Juan", lastname: "Alcantara", email: "juan@mail.com", id: 1})
      created = connc
      |> put_req_header("authorization", "Bearer "<>token_auth)
      |> post(Routes.user_path(connc, :create_user, %{name: "Juan", lastname: "Rincón", email: "juan@example.com"}))
      |> json_response(201)

      {:ok, params: created}
    end

    test "Error when user is not active", %{params: params} do
      conn = build_conn()
      response =
        conn
        |> post(Routes.session_path(conn, :create_session, %{email: params["user"]["email"], password: "Qwerty2021"}))
        |> json_response(400)

      assert %{
        "error" => _error
      } = response
    end
  end

  describe "[DELETE] /logout:" do
    test "Redirect to login" do
      conn = build_conn()

      conn
      |> delete(Routes.session_path(conn, :delete_session))
      |> response(205)
    end
  end

end
