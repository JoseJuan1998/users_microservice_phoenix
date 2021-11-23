defmodule HangmanWeb.Router do
  use HangmanWeb, :router

  pipeline :api do
    plug CORSPlug,
    send_preflight_response?: false,
    origin: [
      "http://localhost:3000",
      "http://hangmangame1.eastatus.cloudapp.azure.com:3000"
    ]
    plug :accepts, ["json"]
    plug HangmanWeb.Authenticate
  end

  scope "/manager", HangmanWeb do
    pipe_through :api

    options "/", OptionsController, :options
    options "/users/:id", OptionsController, :options
    options "/users/:np/:nr", OptionsController, :options
    options "/users", OptionsController, :options
    # coveralls-ignore-start
    options "/users/pass/:id", OptionsController, :options
    options "/users/pass", OptionsController, :options
    options "/users/name/:id", OptionsController, :options
    options "/users/name", OptionsController, :options
    options "/users/reset/pass", OptionsController, :options
    # coveralls-ignore-stop

    get "/users/:id", UserController, :get_user
    get "/users", UserController, :get_users
    get "/users/:np/:nr", UserController, :get_users
    post "/users", UserController, :create_user
    put "/users/name/:id", UserController, :update_name
    put "/users/name", UserController, :update_name
    put "/users/pass/:id", UserController, :update_password
    put "/users/pass", UserController, :update_password
    post "/users/reset/pass", UserController, :send_reset_password
    delete "/users/:id", UserController, :delete_user
    delete "/users", UserController, :delete_user

    options "/login", OptionsController, :options
    options "/logout", OptionsController, :options

    post "/login", SessionController, :create_session
    delete "/logout", SessionController, :delete_session
  end

  ## Swagger
  # coveralls-ignore-start
  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "Users API"
      }
    }
  end
  # coveralls-ignore-stop
  # if Mix.env == :dev do
  #   forward "/sent_emails", Bamboo.EmailPreviewPlug
  # end

  scope "/manager/doc" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI,
      otp_app: :hangman,
      swagger_file: "swagger.json"
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).


  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.

end
