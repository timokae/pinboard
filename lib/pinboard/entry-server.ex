defmodule Pinboard.EntryServer do
  use GenServer
  alias Pinboard.EntryImpl

  # External
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def check_pinboard do
    GenServer.cast(__MODULE__, { :check })
  end

  # Internal
  def init(_) do
    IO.puts "EntryServer started"
    { :ok, [] }
  end

  def handle_cast({:check, }, _state) do
    emails = System.get_env("EMAILS")
    latest = EntryImpl.open_latest("state.txt")

    EntryImpl.fetch_all_entries
    |> EntryImpl.filter_new_entries(latest)
    |> EntryImpl.save_latest
    |> EntryImpl.send_notification(emails)
    
    {:noreply, []}
  end
  
  def bla(list) do
    IO.puts inspect(list)
  end

  def terminate(reason, _) do
    IO.puts inspect(reason)
  end
end
