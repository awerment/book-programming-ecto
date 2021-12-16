defmodule EctoPhoenixWeb.PageController do
  use EctoPhoenixWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
