defmodule Celeste.Router do
  use Celeste.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  pipeline :api_private do
    plug Guardian.Plug.EnsureAuthenticated
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
