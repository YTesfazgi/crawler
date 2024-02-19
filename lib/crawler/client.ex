defmodule Crawler.Client do
  @moduledoc """
  Documentation for `Client.Crawler`.
  """

  @doc """
  Simple web crawler using streams.

  ## Examples

      iex> "https://www.ft.com/"
      |> Crawler.Client.stream_urls_from()
      |> Enum.take(10)

      ["https://www.ft.com/accessibility", "https://www.ft.com//#site-navigation",
      "https://www.ft.com//#site-content", "https://www.ft.com//#site-footer",
      "https://markets.ft.com/data", "https://www.ft.com///login?location=/",
      "https://www.ft.com///products?segmentId=f860e6c2-18af-ab30-cd5e-6e3a456f9265",
      "https://www.ft.com//#o-header-drawer",
      "https://www.ft.com//#o-header-search-primary", "https://www.ft.com///"]
  """

  alias Crawler.Parser

  def stream_urls_from(host_url) do
    Stream.resource(
      fn -> {[host_url], []} end,
      fn
        {[], _already_found} ->
          {:halt, []}
        {urls, already_found} ->
          next_urls =
            urls
            |> get_next_urls()
            |> Enum.dedup()
            |> Enum.reject(&Enum.member?(already_found, &1))
            |> Enum.map(&append_host_if_needed(&1, host_url))

          {next_urls, next_urls}
      end,
      fn _ -> :ok end
    )
  end

  defp append_host_if_needed("http" <> _rest = url, _host_url), do: url
  defp append_host_if_needed(path, host_url), do: host_url <> "/" <> path

  defp get_next_urls(urls) do
    urls
    |> Enum.map(&parse_page/1)
    |> Enum.map(fn {:ok, urls} -> urls end)
    |> List.flatten()
  end

  defp parse_page(url) do
    HTTPoison.get(url)
    |> parse_links_from_response()
  end

  defp parse_links_from_response({:ok, %HTTPoison.Response{body: body}}) do
    Parser.find_links(body)
  end
  defp parse_links_from_response({:error, reason}), do: {:error, reason}
end
