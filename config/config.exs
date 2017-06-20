use Mix.Config

config :brod,
  clients: [
    kafka_client: [
      endpoints: [{'localhost', 9092}],
      auto_start_producers: true
    ]
  ]

config :kafka_consumer,
  max_restarts: 3,
  max_seconds: 5,
  consumers: []
