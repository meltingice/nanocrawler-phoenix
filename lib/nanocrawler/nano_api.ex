defmodule Nanocrawler.NanoAPI do
  def rpc(action, options \\ %{}) do
    request_body = Map.merge(%{action: action}, options) |> Jason.encode!()

    resp =
      :httpc.request(
        :post,
        {rpc_host(), [], 'application/json', request_body},
        [],
        []
      )

    case resp do
      {:ok, {_, _, body}} ->
        Jason.decode!(body) |> process_response

      _ ->
        resp
    end
  end

  defp rpc_host do
    to_charlist(Application.get_env(:nanocrawler, NanocrawlerWeb.Endpoint)[:nano][:rpc_host])
  end

  defp process_response(data) do
    case data do
      %{"error" => error} -> {:error, error}
      _ -> {:ok, data}
    end
  end
end
