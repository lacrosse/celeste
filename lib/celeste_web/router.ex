defmodule CelesteWeb.Router do
  use CelesteWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(Guardian.Plug.VerifyHeader, realm: "Bearer")
    plug(Guardian.Plug.LoadResource)
  end

  pipeline :api_private do
    plug(Guardian.Plug.EnsureAuthenticated)
    plug(Guardian.Plug.EnsureResource)
  end

  scope "/api", CelesteWeb.API do
    pipe_through([:api])

    get("/", RootController, :ping)
    resources("/session", SessionController, only: [:create], singleton: true)
    # legacy
    resources("/files", FileController, only: [:show])
  end

  scope "/api", CelesteWeb.API do
    pipe_through([:api, :api_private])

    resources("/user", UserController, only: [:show, :update], singleton: true)
    resources("/assemblages", AssemblageController, only: [:show])
    get("/news", NewsController, :index)
    get("/composers", AssemblageController, :composers)
    get("/performers", AssemblageController, :performers)
    # get "/stats"
  end

  resources("/files", Celeste.API.FileController, only: [:show])
end
