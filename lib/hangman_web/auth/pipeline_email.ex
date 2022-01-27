defmodule HangmanWeb.Auth.PipelineEmail do
  alias HangmanWeb.Auth
  use Guardian.Plug.Pipeline,
    otp_app: :hangman,
    module: Auth.Guardian,
    error_handler: Auth.ErrorHandler

    plug Guardian.Plug.VerifySession, claims: %{"typ" => "email"}
    plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "email"}
    plug Guardian.Plug.LoadResource, allow_blank: true
    plug Guardian.Plug.EnsureAuthenticated
end
