defmodule NanocrawlerWeb.Api.V2.AccountsController do
  use NanocrawlerWeb, :controller
  alias Nanocrawler.NanoAPI
  import Nanocrawler.Cache
  import Nanocrawler.Util, only: [account_is_valid?: 1]

  def show(conn, %{"account" => account}) do
    cond do
      account_is_valid?(account) ->
        rpc_data =
          fetch("v2/account/#{account}", 10, fn ->
            NanoAPI.rpc("account_info", %{
              account: account,
              representative: true,
              weight: true,
              pending: true
            })
          end)

        case rpc_data do
          {:ok, data} ->
            json(conn, %{account: data})

          {:error, "Bad account number" = data} ->
            conn |> put_status(:bad_request) |> json(%{error: data})

          {:error, "Account not found" = data} ->
            conn |> put_status(:not_found) |> json(%{error: data})

          {:error, msg} ->
            conn |> put_status(500) |> json(%{error: msg})
        end

      true ->
        conn |> put_status(:bad_request) |> json(%{error: "Account is invalid"})
    end
  end

  def weight(conn, %{"account" => account}) do
    cond do
      account_is_valid?(account) ->
        rpc_data =
          fetch("v2/account/#{account}/weight", 300, fn ->
            NanoAPI.rpc("account_weight", %{account: account})
          end)

        case rpc_data do
          {:ok, data} -> json(conn, %{weight: data})
          {:error, msg} -> conn |> put_status(500) |> json(%{error: msg})
        end

      true ->
        conn |> put_status(:bad_request) |> json(%{error: "Account is invalid"})
    end
  end
end
