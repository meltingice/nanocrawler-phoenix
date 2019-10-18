defmodule Nanocrawler.NanoAPI do
  def rpc(action, options \\ %{}) do
    # Filter nil values
    options = options |> Enum.filter(fn {_, v} -> !is_nil(v) end) |> Enum.into(%{})
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
    to_charlist(Application.get_env(:nanocrawler, :rpc)[:host])
  end

  defp process_response(data) do
    case data do
      %{"error" => error} -> {:error, error}
      _ -> {:ok, data}
    end
  end
end
