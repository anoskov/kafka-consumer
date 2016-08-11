defmodule KafkaConsumer.Mixfile do
  use Mix.Project

  def project do
    [app: :kafka_consumer,
     version: "1.0.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     description: description(),
     package: package()]
  end

  def application do
    [applications: [:kafka_ex] ++ applications(Mix.env)]
  end

  def applications(_),     do: []

  defp deps do
    [{:kafka_ex, "0.5.0"}]
  end

  defp description do
    "Consumer for Kafka using kafka_ex"
  end

  defp package do
    [name: :ccs_sdk,
     files: ["lib", "mix.exs"],
     maintainers: ["Andrey Noskov"],
     licenses: ["MIT"],
     links: %{}]
  end
end
