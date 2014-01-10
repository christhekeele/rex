defmodule Rex.Mixfile do

  use Mix.Project

  def project, do: [
    app: :rex,
    version: "0.0.1",
    elixir: "~> 0.12.2-dev",
    deps: deps
  ]

  def application, do: [
    mod: []# { Rex, [] }
  ]

  defp deps, do: []

end
