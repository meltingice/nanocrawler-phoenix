defmodule NanocrawlerWeb.Api.V3.AccountsController do
  use NanocrawlerWeb, :controller
  alias NanocrawlerWeb.Helpers.CommonErrors
  alias Nanocrawler.NanoAPI
  import Nanocrawler.Cache
  import Nanocrawler.Util, only: [account_is_valid?: 1, timestamp_for_block: 1]

  plug :validate_account

  def show(conn, %{"account" => account}) do
    rpc_data =
      fetch("v3/account/#{account}", 10, fn ->
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

  def weight(conn, %{"account" => account}) do
    rpc_data =
      fetch("v3/account/#{account}/weight", 300, fn ->
        NanoAPI.rpc("account_weight", %{account: account})
      end)

    case rpc_data do
      {:ok, data} -> json(conn, %{weight: data})
      {:error, msg} -> conn |> put_status(500) |> json(%{error: msg})
    end
  end

  def delegators(conn, %{"account" => account}) do
    rpc_data =
      fetch("v3/account/#{account}/delegators", 300, fn ->
        NanoAPI.rpc("delegators", %{account: account})
      end)

    case rpc_data do
      {:ok, data} -> json(conn, data)
      {:error, msg} -> conn |> put_status(500) |> json(%{error: msg})
    end
  end

  def history(conn, %{"account" => account} = params) do
    rpc_data =
      fetch("v3/account/#{account}/history/#{params["head"] || ""}", 10, fn ->
        NanoAPI.rpc("account_history", %{
          account: account,
          count: 50,
          raw: true,
          head: params["head"]
        })
      end)

    case rpc_data do
      {:ok, %{"history" => ""}} ->
        conn |> put_status(:not_found) |> json(CommonErrors.account_not_found())

      {:ok, %{"history" => history}} ->
        history =
          Enum.map(history, fn entry ->
            Map.merge(entry, %{"timestamp" => timestamp_for_block(entry["hash"])})
          end)

        json(conn, %{"history" => history})

      {:error, "Bad account number" = data} ->
        conn |> put_status(:bad_request) |> json(%{error: data})

      {:error, msg} ->
        conn |> put_status(500) |> json(%{error: msg})
    end
  end

  def pending(conn, %{"account" => account}) do
    data =
      fetch("v3/account/#{account}/pending", 10, fn ->
        rpc_data =
          NanoAPI.rpc("accounts_pending", %{
            accounts: [account],
            source: true,
            # 0.000001
            threshold: "1000000000000000000000000",
            sorting: true
          })

        case rpc_data do
          {:ok, %{"blocks" => accounts}} ->
            all_blocks = get_all_blocks_from_accounts(accounts)
            blocks = format_pending_blocks(all_blocks)

            case NanoAPI.rpc("account_balance", %{account: account}) do
              {:ok, %{"pending" => pending_balance}} ->
                {:ok,
                 %{
                   total: map_size(all_blocks),
                   blocks: blocks,
                   pendingBalance: pending_balance
                 }}

              {:error, msg} ->
                {:error, msg}
            end

          true ->
            rpc_data
        end
      end)

    case data do
      {:ok, resp} -> json(conn, resp)
      {:error, msg} -> conn |> put_status(500) |> json(%{error: msg})
    end
  end

  defp get_all_blocks_from_accounts(accounts) do
    # Since we're really only fetching 1 account, we can just grab the only entry in the Map.
    case accounts[Map.keys(accounts) |> hd] do
      %{} = all_blocks -> all_blocks
      _ -> %{}
    end
  end

  defp format_pending_blocks(all_blocks) do
    # Because some accounts can have a ton of pending transactions, we're only interested in
    # the first 20.
    all_blocks
    |> Map.to_list()
    |> Enum.slice(0, 20)
    |> Enum.into(%{})
    |> Enum.map(fn {hash, block} ->
      %{
        type: "pending",
        amount: block["amount"],
        hash: hash,
        source: block["source"],
        timestamp: timestamp_for_block(hash)
      }
    end)
  end

  defp validate_account(conn, _) do
    cond do
      account_is_valid?(conn.params["account"]) ->
        conn

      true ->
        conn |> put_status(:bad_request) |> json(CommonErrors.account_invalid())
    end
  end
end
