defmodule Nanocrawler.RpcClient.IpcClient do
  use Nanocrawler.RpcClient.BaseClient
  @timeout 60_000

  @impl true
  def rpc(action, options \\ %{}) do
    options = options |> Enum.filter(fn {_, v} -> !is_nil(v) end) |> Enum.into(%{})
    request_body = Map.merge(%{action: action}, options)

    :poolboy.transaction(
      :nano_ipc,
      fn pid -> Nanocrawler.RpcClient.Ipc.call(pid, request_body) end,
      @timeout
    )
  end
end
