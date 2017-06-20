defmodule KafkaConsumer.Mixfile do
  use Mix.Project

  def project do
    [app: :kafka_consumer,
     version: "2.0.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:brod, "~> 2.4.1"},
     {:ex_doc, ">= 0.0.0", only: :dev}]
  end

  defp description do
    "Consumer for Kafka using brod"
  end

  defp package do
    [name: :kafka_consumer,
     files: ["lib", "mix.exs"],
     maintainers: ["Andrey Noskov", "Yuri Artemev"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/anoskov/kafka-consumer"}]
  end
end
