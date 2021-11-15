defmodule HangmanWeb.OptionsController do
  use HangmanWeb, :controller

  def options(conn, _params) do
    conn
      |> resp(204, "")
      |> put_resp_header(
        "acces-control-allow-headers",
        "authorization, Content-Type, Accept, Origon, User-Agent, DNT, Cache-Control, X-Mx-ReqToken, Keep-Alive, X-Requested-With, If-Modified-Since, X-CSRF-Token, access-control-allow-origin"
      )
      |> send_resp()
  end
end
