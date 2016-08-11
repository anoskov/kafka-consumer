use Mix.Config

config :kafka_consumer,
  default_pool_size: 5,
  default_pool_max_overflow: 10,
  event_handlers: []

import_config "#{Mix.env}.exs"
