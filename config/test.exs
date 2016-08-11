use Mix.Config

config :logger, level: :warn

config :kafka_ex,
  brokers: [{"localhost", 9092}],
  consumer_group: "kafka_ex",
  disable_default_worker: false,
  sync_timeout: 3000,
  max_restarts: 10,
  max_seconds: 60

config :kafka_consumer,
  event_handlers: [
    {"topic", 1, KafkaConsumer.TestEventHandler, :handler_pool, 5, 5}
  ]
