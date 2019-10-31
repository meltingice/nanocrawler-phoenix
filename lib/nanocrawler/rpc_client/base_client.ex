defmodule Nanocrawler.RpcClient.BaseClient do
  defmacro __using__(_) do
    quote location: :keep do
      @behaviour Nanocrawler.RpcClient.Behaviour

      defp process_response(data) do
        case data do
          %{"error" => error} -> {:error, error}
          _ -> {:ok, data}
        end
      end
    end
  end
end
