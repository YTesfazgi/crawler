# Crawler

**Simple Elixir web crawler.**

## Usage

`
  iex -S mix run

  iex(1)> "https://www.ft.com/"
  iex(2)> |> Crawler.Client.stream_urls_from()
  iex(3)> |> Enum.take(10)

  ["https://www.ft.com/accessibility", "https://www.ft.com//#site-navigation",
  "https://www.ft.com//#site-content", "https://www.ft.com//#site-footer",
  "https://markets.ft.com/data", "https://www.ft.com///login?location=/",
  "https://www.ft.com///products?segmentId=f860e6c2-18af-ab30-cd5e-6e3a456f9265",
  "https://www.ft.com//#o-header-drawer",
  "https://www.ft.com//#o-header-search-primary", "https://www.ft.com///"]
`
