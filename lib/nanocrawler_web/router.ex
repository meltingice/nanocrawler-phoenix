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
  scope "/api", NanocrawlerWeb.Api do
    pipe_through :api

    scope "/v3", V3 do
      scope "/accounts" do
        get "/:account", AccountsController, :show
        get "/:account/weight", AccountsController, :weight
        get "/:account/delegators", AccountsController, :delegators
        get "/:account/history", AccountsController, :history
        get "/:account/pending", AccountsController, :pending
      end

      scope "/blocks" do
        get "/:hash", BlocksController, :show
      end

      scope "/network" do
        get "/active_difficulty", NetworkController, :active_difficulty
        get "/confirmation_history", NetworkController, :confirmation_history
        get "/confirmation_quorum", NetworkController, :confirmation_quorum
        get "/peers", NetworkController, :peers
        get "/tps/:period", NetworkController, :tps
      end

      scope "/node" do
        get "/block_count", NodeController, :block_count
      end

      scope "/representatives" do
        get "/online", RepresentativesController, :online
        get "/official", RepresentativesController, :official
      end
    end
  end

  scope "/", NanocrawlerWeb do
    pipe_through :browser

    get "/*path", HomeController, :index
  end
end
