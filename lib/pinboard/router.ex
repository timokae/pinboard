defmodule Pinboard.Router do
  use Plug.Router
  use Plug.Debugger
  require Logger
  
  @prefix "
    <!DOCTYPE html>
      <html>
      <head>
        <meta charset='UTF-8'>
        <meta name='viewport' content='width=device-width,initial-scale=1'>
        <title>Log</title>
        <style>
          ul {
            list-style-type: none;
            padding-left: 15px;
          }
        </style>
      </head>
    <body>
      <ul>
  "

  @suffix "
        </ul>
      </body>
    </html>
  "


  plug(Plug.Logger, log: :debug)

  plug(:match)
  plug(:dispatch)
  
  get "/log" do
    state = Pinboard.EntryServer.status
    IO.inspect(state)
    body = Enum.reduce(state, "", fn el, acc -> acc <> entry_to_string(el) end)
    response = @prefix <> body <> @suffix
    send_resp(conn, 200, response)
  end
  
  match _ do
    send_resp(conn, 404, "not found")
  end
  

  defp entry_to_string(%{datetime: nil, new: nil}), do: ""
  defp entry_to_string(%{datetime: dt, new: new}) do
    "<li>[#{dt}] #{length(new)} new entries</li>"
  end
end