defmodule Pinboard.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Sequence.Worker.start_link(arg)
      { Pinboard.EntryServer, []},
      # { Pinboard, 3_600_000 },
      { Pinboard, 10_000 },
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pinboard.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
