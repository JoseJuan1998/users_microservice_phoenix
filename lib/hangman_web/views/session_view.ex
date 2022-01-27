defmodule HangmanWeb.SessionView do
  use HangmanWeb, :view

  def render("session.json", %{user: user, token: token}) do
    %{
      user: %{
        id: user.id,
        name: user.name,
        lastname: user.lastname,
        email: user.credential.email,
        active: user.credential.active,
        admin: user.credential.admin
      },
      token: token
    }
  end
end
