defmodule Celeste.Router do
  use Celeste.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :browser_private do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  pipeline :api_private do
    plug Guardian.Plug.EnsureAuthenticated, handler: Celeste.API.Bailiff
  end

  scope "/", Celeste do
    pipe_through [:browser]

    resources "/session", SessionController, only: [:new, :create], singleton: true

    get "/", PageController, :index
  end

  scope "/", Celeste do
    pipe_through [:browser, :browser_private]

    resources "/session", SessionController, only: [:delete], singleton: true

    resources "/assemblages", AssemblageController, only: [:show, :new, :create, :edit]

    get "/composers", AssemblageController, :composers
  end

  scope "/api", Celeste.API do
    pipe_through [:api]

    resources "/session", SessionController, only: [:create], singleton: true
  end

  scope "/api", Celeste.API do
    pipe_through [:api, :api_private]

    resources "/assemblages", AssemblageController, only: [:show]
    resources "/files", FileController, only: [:show]
    get "/composers", AssemblageController, :composers
  end
end
