defmodule EctoPhoenixWeb.Router do
  use EctoPhoenixWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {EctoPhoenixWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EctoPhoenixWeb do
    pipe_through :browser

    get "/", PageController, :index

    # Accounts.User
    live "/users", UserLive.Index, :index
    live "/users/new", UserLive.Index, :new
    live "/users/:id/edit", UserLive.Index, :edit
    live "/users/:id", UserLive.Show, :show
    live "/users/:id/show/edit", UserLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", EctoPhoenixWeb do
  #   pipe_through :api
  # end
end
