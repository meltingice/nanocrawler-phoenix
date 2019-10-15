defmodule NanocrawlerWeb.Api.V2.AccountsController do
  use NanocrawlerWeb, :controller
  alias Nanocrawler.NanoAPI
  import Nanocrawler.Cache

  def show(conn, %{"account" => account}) do
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
  end
end
