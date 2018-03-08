defmodule Celeste.Router do
  use Celeste.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  pipeline :api_private do
    plug Guardian.Plug.EnsureAuthenticated
    plug Guardian.Plug.EnsureResource
  end

  scope "/api", Celeste.API do
    pipe_through [:api]

    get "/", RootController, :ping
    resources "/session", SessionController, only: [:create], singleton: true
    resources "/files", FileController, only: [:show]
  end

  scope "/api", Celeste.API do
    pipe_through [:api, :api_private]

    resources "/assemblages", AssemblageController, only: [:show]
    get "/news", NewsController, :index
    get "/composers", AssemblageController, :composers
    get "/performers", AssemblageController, :performers
  end
end
