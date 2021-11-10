defmodule HangmanWeb.UserView do
  use HangmanWeb, :view

  def render("user.json", %{user: user}) do
    %{user: render("single_user.json", %{user: user})}
  end

  def render("users.json", %{users: users}) do
    %{users: render_many(users, HangmanWeb.UserView,"single_user.json")}
  end

  def render("single_user.json", %{user: user}) do
    %{
      id: user.id,
      name: user.name,
      email: user.credential.email,
      active: user.credential.active
    }
  end
end
