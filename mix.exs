defmodule SaslEx.Mixfile do
  use Mix.Project

  def project do
    [
      app: :sasl_ex,
      version: "0.1.0",
      elixir: "~> 1.1",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps,
      package: package,
      description: description,
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    []
  end

 defp description do
    """
    A lib for decoding bytes in the format of the SASL protocol into an Elixir struct.
    """
  end

  defp package do
    [
       files: ["lib", "priv", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
       maintainers: ["Jason Goldberger"],
       licenses: ["MIT"],
       links: %{"GitHub" => "https://github.com/elbow-jason/sasl_ex"}
    ]
  end

end
