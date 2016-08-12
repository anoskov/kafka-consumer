defmodule KafkaConsumer.Mixfile do
  use Mix.Project

  def project do
    [app: :kafka_consumer,
     version: "1.0.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     aliases: aliases(),
     description: description(),
     package: package()]
  end

  def application do
    [mod: {KafkaConsumer, []},
     applications: [:kafka_ex, :poolboy, :gproc]]
  end

  defp deps do
    [{:kafka_ex, "0.5.0"},
     {:poolboy, "~> 1.5"},
     {:gproc, "~> 0.5.0"},
     {:mock, "~> 0.1.1", only: :test},
     {:ex_doc, ">= 0.0.0", only: :dev}]
  end

  defp aliases do
    ["test": ["test --no-start"]]
  end

  defp description do
    "Consumer for Kafka using kafka_ex"
  end

  defp package do
    [name: :kafka_consumer,
     files: ["lib", "mix.exs"],
     maintainers: ["Andrey Noskov", "Yuri Artemev"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/anoskov/kafka-consumer"}]
  end
end
