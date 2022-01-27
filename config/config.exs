# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :hangman,
  ecto_repos: [Hangman.Repo]

# Configures Swagger
config :hangman, :phoenix_swagger,
swagger_files: %{
  "priv/static/swagger.json" => [
    router: HangmanWeb.Router,
    endpoint: HangmanWeb.Endpoint
  ]
}

# Configures the endpoint
config :hangman, HangmanWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: HangmanWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Hangman.PubSub,
  live_view: [signing_salt: "SeQJOfSV"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.

# config :hangman, Hangman.Mailer, adapter: Swoosh.Adapters.Local
config :hangman, Hangman.Email,
adapter: Bamboo.SMTPAdapter,
server: "smtp.sendgrid.net",
hostname: "smtp.sendgrid.net",
port: 587,
username: "apikey",
password: System.get_env("EMAIL_KEY"),
tls: :if_available,
allowed_tls_versions: [:"tlsv1", :"tlsv1.1", :"tlsv1.2"],
ssl: false,
retries: 1,
no_mx_lookups: false,
auth: :if_available

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :hangman, HangmanWeb.Auth.Guardian,
  issuer: "hangman",
  secret_key: System.get_env("GUARDIAN_KEY")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
