defmodule Nanocrawler.RpcClient.Ipc do
  use GenServer
  @opts [:binary, active: false, reuseaddr: true]
  @timeout 30000

  @impl true
  def init(%{ipc_type: :local, path: path} = state) do
    case :gen_tcp.connect({:local, path}, 0, @opts) do
      {:ok, socket} -> {:ok, %{state | socket: socket}}
      {:error, reason} -> {:error, reason}
    end
  end

  @impl true
  def init(%{ipc_type: :tcp, url: url} = state) do
    [host, port] = String.split(url, ":")

    ip =
      host
      |> String.split(".")
      |> Enum.map(fn x -> String.to_integer(x) end)
      |> List.to_tuple()

    port = String.to_integer(port)

    case :gen_tcp.connect(ip, port, @opts) do
      {:ok, socket} -> {:ok, %{state | socket: socket}}
      {:error, reason} -> {:error, reason}
    end
  end

  def call(pid, request) do
    GenServer.call(pid, {:request, request})
  end

  def start_link(state \\ %{}) do
    GenServer.start_link(__MODULE__, Map.merge(state, %{socket: nil}))
  end

  @impl true
  def handle_call({:request, request}, _from, %{socket: socket} = state) do
    response =
      socket
      |> :gen_tcp.send(request |> format_request())
      |> receive_response(socket)

    {:reply, response, state}
  end

  defp format_request(request) do
    encoded_request = Jason.encode!(request)
    <<78, 1, 0, 0, String.length(encoded_request)::size(32)>> <> encoded_request
  end

  defp receive_response(data, socket, result \\ %{length: nil, data: <<>>})

  defp receive_response({:error, reason}, _socket, _result) do
    {:error, reason}
  end

  defp receive_response(:ok, socket, result) do
    with {:ok, response} <- :gen_tcp.recv(socket, 0, @timeout) do
      case result[:length] do
        nil ->
          <<resp_size::size(32), json_data::binary>> = response

          result
          |> Map.put(:length, resp_size)
          |> Map.put(:data, result[:data] <> json_data)
          |> process_result(socket)

        _ ->
          result |> Map.put(:data, result[:data] <> response) |> process_result(socket)
      end
    end
  end

  defp process_result(result, socket) do
    if String.length(result[:data]) >= result[:length] do
      case Jason.decode!(result[:data]) do
        %{"error" => reason} -> {:error, reason}
        data -> {:ok, data}
      end
    else
      receive_response(:ok, socket, result)
    end
  end
end
