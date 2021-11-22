defmodule HangmanWeb.OptionsControllerTest do
  use HangmanWeb.ConnCase

  setup_all do: []

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  # Info
  describe "[OPTIONS] /manager/:" do
    test "Returns the CORS options" do
      conn = build_conn()
      conn_response = options(conn, Routes.options_path(conn, :options))

      assert response(conn_response, :no_content) == ""
      assert get_resp_header(conn_response, "access-control-allow-methods") ==
        ["GET,POST,PUT,PATCH,DELETE,OPTIONS"]
      assert get_resp_header(conn_response, "access-control-allow-headers") ==
        ["Authorization,Content-Type,Accept,Origin,User-Agent,DNT,Cache-Control,X-Mx-ReqToken,Keep-Alive,X-Requested-With,If-Modified-Since,X-CSRF-Token"]
    end
  end

  describe "[OPTIONS] /manager/users/:id:" do
    test "Returns the CORS options" do
      conn = build_conn()
      conn_response = options(conn, "/manager/users/1")

      assert response(conn_response, :no_content) == ""
      assert get_resp_header(conn_response, "access-control-allow-methods") ==
        ["GET,POST,PUT,PATCH,DELETE,OPTIONS"]
      assert get_resp_header(conn_response, "access-control-allow-headers") ==
        ["Authorization,Content-Type,Accept,Origin,User-Agent,DNT,Cache-Control,X-Mx-ReqToken,Keep-Alive,X-Requested-With,If-Modified-Since,X-CSRF-Token"]
    end
  end

  describe "[OPTIONS] /manager/users/:" do
    test "Returns the CORS options" do
      conn = build_conn()
      conn_response = options(conn, "/manager/users")

      assert response(conn_response, :no_content) == ""
      assert get_resp_header(conn_response, "access-control-allow-methods") ==
        ["GET,POST,PUT,PATCH,DELETE,OPTIONS"]
      assert get_resp_header(conn_response, "access-control-allow-headers") ==
        ["Authorization,Content-Type,Accept,Origin,User-Agent,DNT,Cache-Control,X-Mx-ReqToken,Keep-Alive,X-Requested-With,If-Modified-Since,X-CSRF-Token"]
    end
  end

  describe "[OPTIONS] /manager/users/pass/:id:" do
    test "Returns the CORS options" do
      conn = build_conn()
      conn_response = options(conn, "/manager/users/pass/1")

      assert response(conn_response, :no_content) == ""
      assert get_resp_header(conn_response, "access-control-allow-methods") ==
        ["GET,POST,PUT,PATCH,DELETE,OPTIONS"]
      assert get_resp_header(conn_response, "access-control-allow-headers") ==
        ["Authorization,Content-Type,Accept,Origin,User-Agent,DNT,Cache-Control,X-Mx-ReqToken,Keep-Alive,X-Requested-With,If-Modified-Since,X-CSRF-Token"]
    end
  end

  describe "[OPTIONS] /manager/users/pass/:" do
    test "Returns the CORS options" do
      conn = build_conn()
      conn_response = options(conn, "/manager/users/pass")

      assert response(conn_response, :no_content) == ""
      assert get_resp_header(conn_response, "access-control-allow-methods") ==
        ["GET,POST,PUT,PATCH,DELETE,OPTIONS"]
      assert get_resp_header(conn_response, "access-control-allow-headers") ==
        ["Authorization,Content-Type,Accept,Origin,User-Agent,DNT,Cache-Control,X-Mx-ReqToken,Keep-Alive,X-Requested-With,If-Modified-Since,X-CSRF-Token"]
    end
  end

  describe "[OPTIONS] /manager/users/name/:id:" do
    test "Returns the CORS options" do
      conn = build_conn()
      conn_response = options(conn, "/manager/users/name/1")

      assert response(conn_response, :no_content) == ""
      assert get_resp_header(conn_response, "access-control-allow-methods") ==
        ["GET,POST,PUT,PATCH,DELETE,OPTIONS"]
      assert get_resp_header(conn_response, "access-control-allow-headers") ==
        ["Authorization,Content-Type,Accept,Origin,User-Agent,DNT,Cache-Control,X-Mx-ReqToken,Keep-Alive,X-Requested-With,If-Modified-Since,X-CSRF-Token"]
    end
  end

  describe "[OPTIONS] /manager/users/name/:" do
    test "Returns the CORS options" do
      conn = build_conn()
      conn_response = options(conn, "/manager/users/name")

      assert response(conn_response, :no_content) == ""
      assert get_resp_header(conn_response, "access-control-allow-methods") ==
        ["GET,POST,PUT,PATCH,DELETE,OPTIONS"]
      assert get_resp_header(conn_response, "access-control-allow-headers") ==
        ["Authorization,Content-Type,Accept,Origin,User-Agent,DNT,Cache-Control,X-Mx-ReqToken,Keep-Alive,X-Requested-With,If-Modified-Since,X-CSRF-Token"]
    end
  end

  describe "[OPTIONS] /manager/users/reset/pass:" do
    test "Returns the CORS options" do
      conn = build_conn()
      conn_response = options(conn, "/manager/users/reset/pass")

      assert response(conn_response, :no_content) == ""
      assert get_resp_header(conn_response, "access-control-allow-methods") ==
        ["GET,POST,PUT,PATCH,DELETE,OPTIONS"]
      assert get_resp_header(conn_response, "access-control-allow-headers") ==
        ["Authorization,Content-Type,Accept,Origin,User-Agent,DNT,Cache-Control,X-Mx-ReqToken,Keep-Alive,X-Requested-With,If-Modified-Since,X-CSRF-Token"]
    end
  end

  describe "[OPTIONS] /manager/login:" do
    test "Returns the CORS options" do
      conn = build_conn()
      conn_response = options(conn, "/manager/login")

      assert response(conn_response, :no_content) == ""
      assert get_resp_header(conn_response, "access-control-allow-methods") ==
        ["GET,POST,PUT,PATCH,DELETE,OPTIONS"]
      assert get_resp_header(conn_response, "access-control-allow-headers") ==
        ["Authorization,Content-Type,Accept,Origin,User-Agent,DNT,Cache-Control,X-Mx-ReqToken,Keep-Alive,X-Requested-With,If-Modified-Since,X-CSRF-Token"]
    end
  end

  describe "[OPTIONS] /manager/logout:" do
    test "Returns the CORS options" do
      conn = build_conn()
      conn_response = options(conn, "/manager/logout")

      assert response(conn_response, :no_content) == ""
      assert get_resp_header(conn_response, "access-control-allow-methods") ==
        ["GET,POST,PUT,PATCH,DELETE,OPTIONS"]
      assert get_resp_header(conn_response, "access-control-allow-headers") ==
        ["Authorization,Content-Type,Accept,Origin,User-Agent,DNT,Cache-Control,X-Mx-ReqToken,Keep-Alive,X-Requested-With,If-Modified-Since,X-CSRF-Token"]
    end
  end
end
