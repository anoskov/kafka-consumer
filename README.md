# Kafka consumer

Scalable consumer for Kafka using kafka_ex, poolboy and elixir.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

* Add `kafka_consumer` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:kafka_consumer, github: "anoskov/kafka-consumer"}]
end
```

* Ensure `kafka_consumer` is started before your application:

```elixir
def application do
  [applications: [:kafka_consumer]]
end
```

## Usage

* Set config or pass default attributes
```elixir
config :kafka_ex,
  brokers: [{"localhost", 9092}],
  consumer_group: "kafka_ex" ,
  sync_timeout: 3000,
  max_restarts: 10,
  max_seconds: 60
```

* Write your own EventHandler. Functions start_link/1 and handle_event/2 is overridable
```elixir
defmodule EventHandler do
  use KafkaConsumer.EventHandler

  def handle_cast({topic, _partition, message}, state) do
    Logger.debug "from #{topic} message: #{inspect message}"
    {:noreply, state}
  end
end
```

* Set event handlers in config. Format - {topic_name, partition, handler, handler_pool, size, max_overflow}
```elixir
config :kafka_consumer,
  event_handlers: [
    {"topic", 0, KafkaConsumer.TestEventHandler, :handler_pool, 5, 5},
    {"topic2", 0, KafkaConsumer.TestEventHandler, :handler_pool, 5, 5},
  ]
```

* Start your app.
