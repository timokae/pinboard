defmodule Pinboard.EntryImpl do
  require IEx
  alias Pinboard.{Mailer, Email}
  
  def send_notification([], _), do: []
  def send_notification(list, emails) do
    emails
    |> String.split(";")
    |> Enum.map(&Email.test_mail(&1, list))
    |> Enum.each(&Mailer.deliver_now/1)
    
    list
  end
  
  def fetch_all_entries do
    Pinboard.Fetcher.token
    |> Pinboard.Fetcher.fetch
    |> Pinboard.Extractor.entries
  end
  
  def filter_new_entries(list, nil), do: list
  def filter_new_entries(list, latest) do
    index = Enum.find_index(list, fn el -> el.content == latest.content end)
    case index do
      nil -> list
        n -> Enum.take(list, n)
    end
  end

  def save_latest([]), do: []
  def save_latest(list) do
    latest = list
    |> sort_entries_by_date
    |> List.first

    encoded_json = Poison.encode!(latest)
    IO.puts encoded_json
    case File.write("state.txt", encoded_json) do
      {:error, msg} -> IO.inspect(msg)
      _             -> IO.puts("Latest entry saved")
    end

    list
  end

  def open_latest(path) do
    case File.read(path) do
      {:ok, ""}      -> nil
      {:ok, content} -> Poison.decode!(content) |> keys_to_atom
      _              -> nil
    end
  end


  defp keys_to_atom(nil), do: nil
  defp keys_to_atom(map) do
    for {key, value} <- map, into: %{}, do: {String.to_atom(key), value}
  end

  defp sort_entries_by_date(list) do
    list |> Enum.sort(&(reverse_date(&1.date) >= reverse_date(&2.date)))
  end

  defp reverse_date(date) do
    date
    |> String.split(".")
    |> Enum.reverse
    |> Enum.join(".")
  end
end
