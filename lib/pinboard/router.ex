defmodule Pinboard.Router do
  use Plug.Router
  use Plug.Debugger
  require Logger

  plug(Plug.Logger, log: :debug)

  plug(:match)
  plug(:dispatch)
  
  get "/hello" do
    state = Pinboard.EntryServer.status
    IO.inspect(state)
    response = Enum.reduce(state, "", fn el, acc -> acc <> entry_to_string(el) end)
    send_resp(conn, 200, response)
  end
  
  match _ do
    send_resp(conn, 404, "not found")
  end
  

  defp entry_to_string(%{datetime: nil, new: nil}), do: ""
  defp entry_to_string(%{datetime: dt, new: new}) do
    "#{dt} #{length(new)} new entries\n"
  end
end