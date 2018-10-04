defmodule Pinboard do
  use GenServer

  alias Pinboard.{Mailer, Email}

  def start_link(time) do
    GenServer.start_link(__MODULE__, time)
  end

  def init(state) do
    schedule_work(state)
    {:ok, state}
  end

  def handle_info(:work, state) do
    # Receive new entries
    check_pinboard()
    schedule_work(state)
    {:noreply, state}
  end

  def schedule_work(state) do
    Process.send_after(self(), :work, state)
  end

  def check_pinboard() do
    saved_entry = Entry.open_latest("state.txt")

    # sorted list of entries
    # list = mock_data()
    list = Pinboard.Fetcher.token
    |> Pinboard.Fetcher.fetch
    |> Pinboard.Extractor.entries

    new_entries = list
    |> Entry.filter_new_entries(saved_entry)

    if length(new_entries) > 0 do
      System.get_env("EMAILS")
      |> String.split(";")
      |> Enum.map(&Email.test_mail(&1, new_entries))
      |> Enum.each(&Mailer.deliver_now/1)
    end

    Entry.save_latest(list)

    {:ok, time_str} = Timex.Timezone.local |> Timex.now |> Timex.format("%Y-%m-%d %H:%M", :strftime)
    IO.puts "#{time_str}: Received #{length(list)} entries, #{length(new_entries)} new."
  end

  def mock_data do
    {:ok, html} = File.read("mock_data.txt")
    html
  end
end
