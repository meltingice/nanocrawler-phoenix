defmodule NanocrawlerWeb.Api.V3.RepresentativesController do
  use NanocrawlerWeb, :controller
  alias Nanocrawler.NanoAPI
  import Nanocrawler.Cache

  def online(conn, _) do
    rpc_data =
      fetch("v3/representatives/online", 300, fn ->
        case NanoAPI.rpc("representatives_online", %{weight: true}) do
          {:ok, %{"representatives" => reps_online}} ->
            {:ok,
             reps_online
             |> Enum.map(fn {account, %{"weight" => weight}} ->
               {account, weight}
             end)
             |> Enum.into(%{})}

          {:error, msg} ->
            {:error, msg}
        end
      end)

    case rpc_data do
      {:ok, representatives} ->
        json(conn, %{representatives: representatives})

      {:error, msg} ->
        conn |> put_status(500) |> json(%{error: msg})
    end
  end

  def official(conn, _) do
    rpc_data =
      fetch("v3/representatives/official", 60, fn ->
        case NanoAPI.rpc("representatives") do
          {:ok, %{"representatives" => reps}} ->
            Application.get_env(:nanocrawler, :network)[:official_representatives]
            |> Enum.map(fn addr ->
              {addr, reps[addr]}
            end)
            |> Enum.into(%{})
            |> (&{:ok, &1}).()

          {:error, _} = resp ->
            resp
        end
      end)

    case rpc_data do
      {:ok, representatives} ->
        json(conn, %{representatives: representatives})

      {:error, msg} ->
        conn |> put_status(500) |> json(%{error: msg})
    end
  end
end
