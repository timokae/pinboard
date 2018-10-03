defmodule Pinboard do
  alias Pinboard.{Mailer, Email}

  def main() do
    saved_entry = open_latest("state.txt") |> keys_to_atom

    # sorted list of entries
    # list = mock_data()
    list = Pinboard.Fetcher.token
    |> Pinboard.Fetcher.fetch
    |> Pinboard.Extractor.entries
    |> Enum.sort(&(reverse_date(&1.date) >= reverse_date(&2.date)))


    new_entries = list
    |> filter_new_entries(saved_entry)

    if length(new_entries) > 0 do
      System.get_env("EMAILS")
      |> String.split(";")
      |> Enum.map(&Email.test_mail(&1, new_entries))
      |> Enum.each(&Mailer.deliver_now/1)
    end

    list
    |> List.first
    |> save_latest
  end

  def mock_data do
    {:ok, html} = File.read("mock_data.txt")
    html
  end

  def reverse_date(date) do
    date
    |> String.split(".")
    |> Enum.reverse
    |> Enum.join(".")
  end

  def save_latest(entry) do
    encoded_json = Poison.encode!(entry)
    case File.write("state.txt", encoded_json) do
      {:error, msg} -> IO.inspect(msg)
      _             -> IO.puts("Latest entry saved")
    end
  end

  def open_latest(path) do
    case File.read(path) do
      {:ok, ""}      -> nil
      {:ok, content} -> Poison.decode!(content)
      _              -> nil
    end
  end

  def filter_new_entries(list, nil), do: list
  def filter_new_entries(list, latest) do
    index = Enum.find_index(list, fn el -> el.content == latest.content end)
    case index do
      nil -> list
        n -> Enum.take(list, n)
    end
  end

  def keys_to_atom(nil), do: nil
  def keys_to_atom(map) do
    for {key, value} <- map, into: %{}, do: {String.to_atom(key), value}
  end
end
