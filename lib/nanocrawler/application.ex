defmodule Nanocrawler.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    [
      # Start the endpoint when the application starts
      NanocrawlerWeb.Endpoint,
      Nanocrawler.Redix
    ]
    |> load_rpc_adapter()
    |> start_application()
  end

  defp load_rpc_adapter(children) do
    # For now, only the IPC client is managed with a pool
    case rpc_type() do
      :ipc ->
        children ++ [:poolboy.child_spec(:ipc_worker, poolboy_config(), ipc_options())]

      _ ->
        children
    end
  end

  defp start_application(children) do
    opts = [strategy: :one_for_one, name: Nanocrawler.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    NanocrawlerWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp rpc_type do
    Application.get_env(:nanocrawler, :rpc)[:type] || :http
  end

  def poolboy_config do
    [
      {:name, {:local, :nano_ipc}},
      {:worker_module, Nanocrawler.RpcClient.Ipc},
      {:size, ipc_max_workers()},
      {:max_overflow, ipc_min_workers()}
    ]
  end

  defp ipc_max_workers do
    Application.get_env(:nanocrawler, :rpc)[:max_worker_count] || ipc_min_workers
  end

  defp ipc_min_workers do
    Application.get_env(:nanocrawler, :rpc)[:min_worker_count] || 5
  end

  defp ipc_options do
    Application.get_env(:nanocrawler, :rpc)
  end
end
