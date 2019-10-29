defmodule NanocrawlerWeb.Api.V3.BlocksController do
  use NanocrawlerWeb, :controller
  alias NanocrawlerWeb.Helpers.CommonErrors
  alias Nanocrawler.NanoAPI
  import Nanocrawler.Cache
  import Nanocrawler.Util, only: [block_hash_is_valid?: 1, timestamp_for_block: 1]

  plug :validate_block_hash

  def show(conn, %{"hash" => hash}) do
    block =
      fetch("v3/block/#{hash}", 604_800, fn ->
        rpc_data =
          NanoAPI.rpc("blocks_info", %{
            hashes: [hash],
            pending: true,
            source: true
          })

        case rpc_data do
          {:ok, %{"blocks" => %{^hash => block}}} ->
            {:ok, process_block(hash, block)}

          true ->
            rpc_data
        end
      end)

    case block do
      {:ok, resp} ->
        json(conn, %{block: resp})

      {:error, "Block not found" = msg} ->
        conn |> put_status(:not_found) |> json(%{error: msg})

      {:error, msg} ->
        conn |> put_status(500) |> json(%{error: msg})
    end
  end

  defp process_block(hash, block) do
    block
    |> Map.merge(%{"timestamp" => timestamp_for_block(hash)})
    |> (&Map.put(&1, "contents", Jason.decode!(&1["contents"]))).()
  end

  defp validate_block_hash(conn, _) do
    cond do
      block_hash_is_valid?(conn.params["hash"]) -> conn
      true -> conn |> put_status(:bad_request) |> json(CommonErrors.block_hash_invalid())
    end
  end
end
