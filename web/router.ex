defmodule Zongora.Router do
  use Zongora.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Zongora do
    pipe_through :browser # Use the default browser stack

    resources "/assemblages", AssemblageController, only: [:show]

    get "/composers", AssemblageController, :composers
  end

  # Other scopes may use custom stacks.
  # scope "/api", Zongora do
  #   pipe_through :api
  # end
end
