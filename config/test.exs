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
  default_pool_size: 5,
  default_pool_max_overflow: 10,
  event_handlers: [
    {KafkaConsumer.TestEventHandler, [{"topic", 1}], size: 5, max_overflow: 10}
  ]
