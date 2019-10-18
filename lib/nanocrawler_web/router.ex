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

  # Other scopes may use custom stacks.
  scope "/api", NanocrawlerWeb do
    pipe_through :api

    scope "/v2" do
      scope "/accounts" do
        get "/:account", Api.V2.AccountsController, :show
        get "/:account/weight", Api.V2.AccountsController, :weight
        get "/:account/delegators", Api.V2.AccountsController, :delegators
        get "/:account/history", Api.V2.AccountsController, :history
        get "/:account/pending", Api.V2.AccountsController, :pending
      end

      scope "/blocks" do
        get "/:hash", Api.V2.BlocksController, :show
      end

      scope "/node" do
        get "/block_count", Api.V2.NodeController, :block_count
      end
    end
  end

  scope "/", NanocrawlerWeb do
    pipe_through :browser

    get "/*path", HomeController, :index
  end
end
