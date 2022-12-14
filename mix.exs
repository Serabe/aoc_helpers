defmodule AocHelpers.MixProject do
  use Mix.Project

  def project do
    [
      app: :aoc_helpers,
      version: "0.5.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: [
        maintainers: ["Sergio Arbeo"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/Serabe/aoc_helpers"},
        description: "Helpers for solving AoC in a LiveBook"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:inets, :logger, :ssl]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [{:ex_doc, ">= 0.0.0", only: :dev, runtime: false}]
  end
end
