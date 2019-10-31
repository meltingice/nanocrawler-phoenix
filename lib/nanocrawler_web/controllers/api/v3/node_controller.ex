defmodule NanocrawlerWeb.Api.V3.NodeController do
  use NanocrawlerWeb, :controller
  alias Nanocrawler.RpcClient
  import Nanocrawler.Cache

  def block_count(conn, _params) do
    rpc_data =
      fetch("block_count", 5, fn ->
        RpcClient.call("block_count")
      end)

    case rpc_data do
      {:ok, data} -> json(conn, data)
      {:error, data} -> conn |> put_status(500) |> json(error: data)
    end
  end
end
