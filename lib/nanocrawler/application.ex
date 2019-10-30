defmodule Nanocrawler.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      NanocrawlerWeb.Endpoint,
      Nanocrawler.Redix
      # Starts a worker by calling: Nanocrawler.Worker.start_link(arg)
      # {Nanocrawler.Worker, arg},
    ]

    case rpc_type() do
      :ipc ->
        children = children ++ [:poolboy.child_spec(:worker, poolboy_config(), ipc_options())]

      :http ->
        nil
    end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
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
      {:worker_module, Nanocrawler.IpcServer},
      {:size, ipc_max_workers()},
      {:max_overflow, ipc_min_workers()}
    ]
  end

  defp ipc_max_workers do
    Application.get_env(:nanocrawler, :rpc)[:max_worker_count] || 5
  end

  defp ipc_min_workers do
    Application.get_env(:nanocrawler, :rpc)[:min_worker_count] || 5
  end

  defp ipc_options do
    rpc = Application.get_env(:nanocrawler, :rpc)

    case rpc[:ipc_type] do
      :local ->
        [ipc_type: :local, path: rpc[:ipc_path]]

      :tcp ->
        [ipc_type: :tcp, url: rpc[:ipc_url]]
    end
  end
end
