defmodule Pinboard do
  use GenServer
  alias Pinboard.EntryServer

  def start_link(time) do
    GenServer.start_link(__MODULE__, time)
  end

  def init(state) do
    IO.puts "PinboardServer starte with #{state}"
    schedule_work(state)
    {:ok, state}
  end

  def handle_info(:work, state) do
    # Receive new entries
    EntryServer.check_pinboard()
    schedule_work(state)

    {:noreply, state}
  end

  def schedule_work(state) do
    Process.send_after(self(), :work, state)
  end
  
  def get_status do
    EntryServer.status
  end

  def mock_data do
    {:ok, html} = File.read("mock_data.txt")
    html
  end
end
