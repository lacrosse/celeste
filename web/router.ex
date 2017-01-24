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
  end

  scope "/api", Celeste.API do
    pipe_through [:api]

    resources "/assemblages", AssemblageController, only: [:show]
    resources "/session", SessionController, only: [:create], singleton: true
  end
end
