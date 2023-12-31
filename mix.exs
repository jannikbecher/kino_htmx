defmodule KinoHtmx.MixProject do
  use Mix.Project

  @version "0.2.0"
  @description "HTMX integration with Livebook"

  def project do
    [
      app: :kino_htmx,
      version: @version,
      description: @description,
      name: "KinoHtmx",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {KinoHtmx.Application, []}
    ]
  end

  defp deps do
    [
      {:kino, "~> 0.10"},
      {:bandit, ">= 0.7.7"},
      {:plug, "~> 1.14"},
      {:phoenix_html, "~> 3.3"},
      {:ex_doc, "~> 0.30", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "KinoHtmx",
      source_url: "https://github.com/jannikbecher/kino_htmx",
      source_ref: "v#{@version}",
      extras: ["README.md"]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jannikbecher/kino_htmx"}
    ]
  end
end
