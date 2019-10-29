defmodule NanocrawlerWeb.Api.V3.NetworkController do
  use NanocrawlerWeb, :controller
  alias Nanocrawler.NanoAPI
  import Nanocrawler.Cache
  import NanocrawlerWeb.Helpers.ResponseHelpers, only: [slice_response: 2]

  def active_difficulty(conn, _) do
    rpc_data =
      fetch("v3/network/active_difficulty", 10, fn ->
        NanoAPI.rpc("active_difficulty", %{include_trend: true})
      end)

    case rpc_data do
      {:ok, data} ->
        json(conn, data)

      {:error, msg} ->
        conn |> put_status(500) |> json(%{error: msg})
    end
  end

  def confirmation_history(conn, params) do
    rpc_data =
      fetch("v3/network/confirmation_history", 10, fn ->
        case NanoAPI.rpc("confirmation_history") do
          {:ok, %{"confirmations" => [_ | _]} = resp} ->
            {:ok,
             Map.put(
               resp,
               "confirmations",
               Enum.sort(resp["confirmations"], fn a, b ->
                 {time_a, _} = Integer.parse(a["time"])
                 {time_b, _} = Integer.parse(b["time"])
                 time_a >= time_b
               end)
             )}

          {:error, _} = resp ->
            resp
        end
      end)

    case rpc_data do
      {:ok, data} ->
        json(
          conn,
          Map.put(data, "confirmations", slice_response(data["confirmations"], params["count"]))
        )

      {:error, msg} ->
        conn |> put_status(500) |> json(%{error: msg})
    end
  end

  def confirmation_quorum(conn, _) do
    rpc_data =
      fetch("v3/network/confirmation_quorum", 10, fn ->
        NanoAPI.rpc("confirmation_quorum")
      end)

    case rpc_data do
      {:ok, data} -> json(conn, data)
      {:error, msg} -> conn |> put_status(500) |> json(%{error: msg})
    end
  end

  def peers(conn, _) do
    rpc_data =
      fetch("v3/network/peers", 300, fn ->
        {:ok, %{"peers" => quorum_peers}} =
          NanoAPI.rpc("confirmation_quorum", %{peer_details: true})

        {:ok, %{"peers" => all_peers}} = NanoAPI.rpc("peers", %{peer_details: true})

        {:ok, combine_peers(quorum_peers, all_peers)}
      end)

    case rpc_data do
      {:ok, peers} ->
        json(conn, %{peers: peers})

      {:error, msg} ->
        conn |> put_status(500) |> json(%{error: msg})
    end
  end

  defp combine_peers(quorum_peers, all_peers) do
    quorum_peers = Enum.map(quorum_peers, &{&1["ip"], &1}) |> Enum.into(%{})

    Enum.map(all_peers, fn {address, peer} ->
      rep_info = quorum_peers[address]

      %{
        ip: address,
        account: if(is_map(rep_info), do: rep_info["account"], else: nil),
        weight: if(is_map(rep_info), do: rep_info["weight"], else: nil),
        protocol_version: peer["protocol_version"],
        type: peer["type"]
      }
    end)
  end

  def tps(conn, %{"period" => period}) do
    case Nanocrawler.TpsCalculator.tps_for_period(period) do
      {:ok, tps} ->
        json(conn, %{tps: tps})

      {:error, "No data yet"} ->
        json(conn, %{tps: 0.0})

      {:error, msg} ->
        conn |> put_status(500) |> json(%{error: msg})
    end
  end
end
