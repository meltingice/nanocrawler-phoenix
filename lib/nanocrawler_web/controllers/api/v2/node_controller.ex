defmodule NanocrawlerWeb.Api.V2.NodeController do
  use NanocrawlerWeb, :controller
  alias Nanocrawler.NanoAPI

  def block_count(conn, _params) do
    case NanoAPI.rpc("block_count") do
      {:ok, data} -> json(conn, data)
      {:error, data} -> conn |> put_status(500) |> json(data)
    end
  end
end
