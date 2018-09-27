defmodule Pinboard do
  alias Pinboard.{Mailer, Email}
  def main() do
    list = mock_data()
    # list = Pinboard.Fetcher.token
    # |> Pinboard.Fetcher.fetch
    |> Pinboard.Extractor.entries

    System.get_env("EMAILS")
    |> String.split(";")
    |> Enum.map(&Email.test_mail(&1, list))
    # |> Email.test_mail
    |> Enum.each(&Mailer.deliver_now/1)
  end

  def mock_data do
    {:ok, html} = File.read("mock_data.txt")
    html
  end
end
