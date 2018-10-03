defmodule Pinboard.MixProject do
  use Mix.Project

  def project do
    [
      app: :pinboard,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :bamboo]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:floki, "~> 0.20.0"},
      {:httpoison, "~> 1.0"},
      {:bamboo, "~> 1.1"},
      {:poison, "~> 3.1"}
    ]
  end

  defp escript do
    [main_module: Pinboard]
  end
end
