defmodule Nanocrawler.TpsCalculator do
  import Nanocrawler.Redix, only: [command: 1]

  @known_periods %{
    "1m" => 60,
    "5m" => 60 * 5,
    "15m" => 60 * 15,
    "30m" => 60 * 30,
    "60m" => 60 * 60,
    "1hr" => 60 * 60,
    "6hr" => 60 * 60 * 6,
    "12hr" => 60 * 60 * 12,
    "24hr" => 60 * 60 * 24,
    "1d" => 60 * 60 * 24,
    "1w" => 60 * 60 * 24 * 7
  }

  @storage_key "nanocrawler/tps"

  def tps_for_period(period) do
    case @known_periods[period] do
      nil ->
        {:error, "Unknown time period or out of allowed range"}

      diff ->
        fetch_tps(diff)
    end
  end

  defp fetch_tps(diff) do
    now = DateTime.utc_now() |> DateTime.to_unix()
    low_bound = now - diff

    case command(["ZRANGEBYSCORE", @storage_key, low_bound, now, "WITHSCORES"]) do
      # Key is missing
      {:ok, data} when is_list(data) and length(data) == 0 ->
        {:error, "No data yet"}

      {:ok, data} when is_list(data) and length(data) > 0 ->
        {start_count, ""} = Integer.parse(data |> hd)
        {end_count, ""} = Integer.parse(Enum.at(data, length(data) - 2))

        {:ok, (end_count - start_count) / (now - low_bound)}

      other ->
        other
    end
  end
end
