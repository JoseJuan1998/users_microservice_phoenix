defmodule HangmanWeb.OptionsControllerTest do
  use HangmanWeb.ConnCase

  setup_all do: []

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  # Info
  describe "[OPTIONS] /:" do
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
end
