defmodule Buraco.MixProject do
  use Mix.Project

  def project do
    [
      app: :buraco,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      name: "Buraco",
      source_url: "https://github.com/uminocelo/buraco",
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Buraco.Application, []}
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      quality: [
        "format --check-formatted",
        "compile -warnings-as-errors",
        "test"
      ]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end
end
