defmodule NanocrawlerWeb.Router do
  use NanocrawlerWeb, :router

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

  scope "/", NanocrawlerWeb do
    pipe_through :browser

    get "/", HomeController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", NanocrawlerWeb do
    pipe_through :api

    scope "/v2" do
      get "/accounts/:account", Api.V2.AccountsController, :show
    end
  end
end
