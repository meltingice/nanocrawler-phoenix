defmodule NanocrawlerWeb.Api.V3.NodeController do
  use NanocrawlerWeb, :controller
  alias Nanocrawler.RpcClient
  import Nanocrawler.Cache

  def block_count(conn, _params) do
    rpc_data =
      fetch("v3/block_count", 5, fn ->
        RpcClient.call("block_count")
      end)

    case rpc_data do
      {:ok, data} -> json(conn, data)
      {:error, data} -> conn |> put_status(500) |> json(error: data)
    end
  end

  def version(conn, _) do
    case fetch("v3/version", 300, fn -> RpcClient.call("version") end) do
      {:ok, data} -> json(conn, data)
      {:error, data} -> conn |> put_status(500) |> json(error: data)
    end
  end

  def system_info(conn, _) do
    case fetch("v3/system_info", 10, fn ->
           memory = :memsup.get_system_memory_data()

           {:ok,
            %{
              memory: %{
                free: memory[:free_memory],
                total: memory[:total_memory]
              },
              raiStats: %{}
            }}
         end) do
      {:ok, data} -> json(conn, data)
      {:error, data} -> conn |> put_status(500) |> json(error: data)
    end
  end
end
