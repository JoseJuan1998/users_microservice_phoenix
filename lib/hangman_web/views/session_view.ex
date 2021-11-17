defmodule HangmanWeb.SessionView do
  use HangmanWeb, :view

  def render("session.json", %{user_id: user_id, token_auth: token_auth}) do
    %{
      user_id: user_id,
      token_auth: token_auth
    }
  end
end
