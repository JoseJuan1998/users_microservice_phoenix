defmodule HangmanWeb.SwaggerTest do
  use HangmanWeb.ConnCase

  setup_all do: []

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "[GET] /doc" do
    test "Index Swagger documentation" do
      conn = build_conn()
      conn
      |> get("/manager/doc/index.html")
      |>response(:ok)
    end

    test "CSS Swagger documentation" do
      conn = build_conn()
      conn
      |> get("/manager/doc/swagger-ui.css")
      |>response(:ok)
    end

    test "JS Swagger documentation" do
      conn = build_conn()
      conn
      |> get("/manager/doc/swagger-ui-standalone-preset.js")
      |>response(:ok)
    end

    test "JS again Swagger documentation" do
      conn = build_conn()
      conn
      |> get("/manager/doc/swagger-ui-bundle.js")
      |>response(:ok)
    end

    test "JSON again Swagger documentation" do
      conn = build_conn()
      conn
      |> get("/manager/doc/swagger.json")
      |>response(:ok)
    end
  end
end
