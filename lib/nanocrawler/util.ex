defmodule Nanocrawler.Util do
  alias Nanocrawler.Redix

  def account_is_valid?(account) do
    String.match?(account, ~r/^\w+_[A-Za-z0-9]{59,60}$/)
  end

  def block_hash_is_valid?(hash) do
    String.match?(hash, ~r/^[A-F0-9]{64}$/)
  end

  def timestamp_for_block(hash) do
    case Redix.command(["GET", "block_timestamp/#{hash}"]) do
      {:ok, nil} -> nil
      {:ok, data} -> data
      {:error, _} -> nil
    end
  end
end
