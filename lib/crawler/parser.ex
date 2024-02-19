defmodule Crawler.Parser do
  @moduledoc """
  Documentation for `Crawler.Parser`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Crawler.Parser.hello()
      :world

  """
  def find_links(html) do
    html
    |> Floki.parse_document()
    |> parse_link_tags()
    |> get_urls()
  end

  defp parse_link_tags({:ok, doc}), do: {:ok, Floki.find(doc, "a")}
  defp parse_link_tags({:error, reason}), do: {:error, reason}

  defp get_urls({:ok, tags}) do
    urls =
      tags
      |> Enum.map(&get_href/1)
      |> Enum.reject(&is_nil/1)

    {:ok, urls}
  end
  defp get_urls({:error, reason}), do: {:error, reason}

  defp get_href({_a, attributes, _children}) do
    case find_href_attr(attributes) do
      {_, value} -> value
      nil -> nil
    end
  end

  defp find_href_attr(attributes) do
    attributes
    |> Enum.find(fn
      {"href", _value} -> true
      _ -> false
    end)
  end
end
