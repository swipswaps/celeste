defmodule Zongora.Router do
  use Zongora.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", Zongora do
    pipe_through [:browser]
    get "/", PageController, :index
  end

  scope "/", Zongora do
    pipe_through [:browser]

    resources "/assemblages", AssemblageController, only: [:show]
    resources "/files", FileController, only: [:show]

    get "/composers", AssemblageController, :composers
  end
end
