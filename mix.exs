defmodule GeminiServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :gemini_server,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {GeminiServer, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.6"},
      {:cors_plug, "~> 3.0"},
      {:json, "~> 1.4"},
      {:httpoison, "~> 2.0"}
    ]
  end
end
