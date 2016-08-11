use Mix.Config

config :kafka_ex,
  brokers: [
    {Application.get_env(:kafka_consumer, :kafka_host) || System.get_env("KAFKA_HOST") || "localhost", 9092}
  ],
  consumer_group: Application.get_env(:kafka_consumer, :consumer_group) || "kafka_ex" ,
  disable_default_worker: false,
  sync_timeout: Application.get_env(:kafka_consumer, :sync_timeout) || 3000,
  max_restarts: Application.get_env(:kafka_consumer, :max_restarts) || 10,
  max_seconds: Application.get_env(:kafka_consumer, :max_seconds) || 60
