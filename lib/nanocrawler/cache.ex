defmodule Nanocrawler.Cache do
  import Nanocrawler.Redix, only: [command: 1]

  def fetch(key, expire, func) do
    case command(["GET", transform_key(key)]) do
      # Key cached
      {:ok, data} when not is_nil(data) -> {:ok, Jason.decode!(data)}
      # Key not stored
      {:ok, nil} -> store(key, expire, func.())
      # Fetch failed, silently continue
      {:error, _} -> {:ok, func.()}
    end
  end

  defp transform_key(key) do
    "nanocrawler/#{key}"
  end

  defp store(key, expire, data) do
    case data do
      {:ok, d} ->
        # We don't check the result of this because we don't care if it fails
        command(["SET", transform_key(key), Jason.encode!(d), "EX", expire])
        {:ok, d}

      _ ->
        data
    end
  end
end
