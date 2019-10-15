defmodule NanocrawlerWeb.Api.V2.NodeController do
  use NanocrawlerWeb, :controller
  alias Nanocrawler.NanoAPI
  import Nanocrawler.Cache

  def block_count(conn, _params) do
    rpc_data =
      fetch("block_count", 5, fn ->
        NanoAPI.rpc("block_count")
      end)

    case rpc_data do
      {:ok, data} -> json(conn, data)
      {:error, data} -> conn |> put_status(500) |> json(error: data)
    end
  end
end
