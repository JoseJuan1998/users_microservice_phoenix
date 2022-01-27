defmodule HangmanWeb.Auth.PipelineAccess do
  alias HangmanWeb.Auth
  use Guardian.Plug.Pipeline,
    otp_app: :hangman,
    module: Auth.Guardian,
    error_handler: Auth.ErrorHandler

    plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
    plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
    plug Guardian.Plug.LoadResource, allow_blank: true
    plug Guardian.Plug.EnsureAuthenticated
end
