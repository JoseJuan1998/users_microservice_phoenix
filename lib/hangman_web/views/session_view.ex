defmodule HangmanWeb.SessionView do
  use HangmanWeb, :view

  def render("session.json", %{user_id: user_id}) do
    %{
      user_id: user_id
    }
  end
end
