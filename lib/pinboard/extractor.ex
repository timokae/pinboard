defmodule Pinboard.Extractor do
  def entries(html) do
    {"table", _, children } = html
    |> Floki.parse
    |> Floki.find(".entries")
    |> List.first

    children
    |> extract_rows([])
  end

  def extract_rows([raw_headline, raw_content|tail], list) do
    {date, href, name} = extract_headline(raw_headline)
    content            = extract_text(raw_content)
    list_element = %{date: date, href: href, name: name, content: content}

    extract_rows(tail, list ++ [list_element])
  end

  def extract_rows([], list), do: list

  def extract_text({"tr", _, content}) do
    content
    |> Floki.text
    # |> String.split
    # |> Enum.join(" ")
  end

  def extract_headline({"tr", _, [raw_date, raw_user]}) do
    date = raw_date
    |> Floki.find("strong")
    |> Floki.text

    href = raw_user
    |> Floki.find("a")
    |> Floki.attribute("href")
    |> List.first

    name = raw_user
    |> Floki.find("a")
    |> Floki.text
    |> String.split
    |> Enum.join(" ")

    {date, href, name}
  end
end
