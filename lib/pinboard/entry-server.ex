defmodule Pinboard.EntryServer do
  use GenServer
  
  alias Pinboard.EntryImpl
  
  require Logger
  
  # External
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def check_pinboard do
    GenServer.cast(__MODULE__, :check)
  end
  
  def status do
    GenServer.call(__MODULE__, :status)
  end

  # Internal
  def init(_) do
    IO.puts "EntryServer started"
    { :ok, [] }
  end

  def handle_cast(:check, state) do
    emails = System.get_env("EMAILS")
    latest = EntryImpl.open_latest("state.txt")

    new_entries = EntryImpl.fetch_all_entries
    |> EntryImpl.filter_new_entries(latest)
    |> EntryImpl.save_latest
    |> EntryImpl.send_notification(emails)
    
    datetime = Timex.local |> Timex.format!("%d.%m.%Y - %H:%M", :strftime)
    IO.puts "#{datetime} >> #{length(new_entries)} new entries"
    {:noreply, [%{datetime: datetime, new: new_entries} | state]}
  end
  
  def handle_call(:status, _from, state) do
    {:reply, state, state}
  end

  def terminate(reason, _) do
    IO.puts inspect(reason)
  end
end
