defmodule NanocrawlerWeb.Helpers.CommonErrors do
  def account_invalid do
    %{error: "Account is invalid"}
  end

  def account_not_found do
    %{error: "Account not found"}
  end
end
