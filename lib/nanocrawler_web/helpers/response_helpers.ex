defmodule NanocrawlerWeb.Helpers.ResponseHelpers do
  def slice_response(list, count) when not is_nil(count) do
    case Integer.parse(count) do
      :error -> list
      {size, _} -> Enum.slice(list, 0, size)
    end
  end

  def slice_response(list, _) do
    list
  end
end
