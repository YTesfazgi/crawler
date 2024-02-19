defmodule Crawler.Client do
  @moduledoc """
  Documentation for `Client.Crawler`.
  """

  @doc """
  Simple web crawler using streams.

  ## Examples

      iex> "https://news.ycombinator.com"
      |> Crawler.Client.stream_urls_from()
      |> Enum.take(10)

      ["https://news.ycombinator.com",
      "https://news.ycombinator.com/news",
      "https://news.ycombinator.com/newest",
      "https://news.ycombinator.com/front",
      "https://news.ycombinator.com/newcomments",
      "https://news.ycombinator.com/ask",
      "https://news.ycombinator.com/show",
      "https://news.ycombinator.com/jobs",
      "https://news.ycombinator.com/submit",
      "https://news.ycombinator.com/login?goto=news"]
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
