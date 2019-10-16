defmodule Nanocrawler.Util do
  def account_is_valid?(account) do
    String.match?(account, ~r/^\w+_[A-Za-z0-9]{59,60}$/)
  end
end
