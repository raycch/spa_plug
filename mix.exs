defmodule SpaPlug.MixProject do
  use Mix.Project

  @version "1.0.0"
  @description "A Plug for serving single page apps"
  @source_url "https://github.com/raycch/spa_plug"

  def project do
    [
      app: :spa_plug,
      name: "SpaPlug",
      version: @version,
      elixir: "~> 1.11",
      deps: deps(),
      description: @description,
      package: package(),
      docs: [
        main: "readme",
        source_ref: "v#{@version}",
        source_url: @source_url,
        extras: ["README.md", "CHANGELOG.md"],
        skip_undefined_reference_warnings_on: [
          "CHANGELOG.md"
        ]
      ],
      source_url: @source_url
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.10"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:mock, "~> 0.3.0", only: :test, runtime: false}
    ]
  end

  defp package do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG*),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end
end
