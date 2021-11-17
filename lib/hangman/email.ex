defmodule Hangman.Email do
  use Bamboo.Mailer, otp_app: :hangman
  use Bamboo.Phoenix, view: HangmanWeb.EmailView
  import Bamboo.Email

  def user_added_email(user, token) do
    new_email()
    |> from({"Hangman Team","hangman_team@outlook.com"})
    |> to({user.name, user.credential.email})
    |> subject("Activate your account")
    |> assign(:user, user)
    |> assign(:token, token)
    |> render("create-user-email.html")
    |> deliver_now()
  end

  def user_reset_password(user, token) do
    new_email()
    |> from({"Hangman Team Support","hangman_team@outlook.com"})
    |> to({user.name, user.credential.email})
    |> subject("Reset your password")
    |> assign(:user, user)
    |> assign(:token, token)
    |> render("reset-user-password.html")
    |> deliver_now()
  end
end
