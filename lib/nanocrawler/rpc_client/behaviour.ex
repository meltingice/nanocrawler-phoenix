defmodule Nanocrawler.RpcClient.Behaviour do
  @callback rpc(String.t(), map()) :: {:ok, map()} | {:error, String.t()}
end
