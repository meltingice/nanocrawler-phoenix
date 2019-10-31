defmodule Nanocrawler.RpcClient do
  alias Nanocrawler.RpcClient.IpcClient
  alias Nanocrawler.RpcClient.HttpClient

  def call(action, options \\ %{}) do
    case Application.get_env(:nanocrawler, :rpc)[:type] do
      :ipc -> IpcClient.rpc(action, options)
      :http -> HttpClient.rpc(action, options)
    end
  end
end
