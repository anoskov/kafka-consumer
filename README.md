# Kafka consumer

Scalable consumer for Kafka using kafka_ex, poolboy and elixir.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

* Add `kafka_consumer` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:kafka_consumer, "~> 1.0"}]
end
```

* Ensure `kafka_consumer` and `gproc` is started before your application:

```elixir
def application do
  [applications: [:kafka_consumer, :gproc]]
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
  require Logger

  def handle_cast({topic, _partition, message}, state) do
    Logger.debug "from #{topic} message: #{inspect message}"
    {:noreply, state}
  end
end
```

* Set event handlers in config.

```elixir
config :kafka_consumer,
  default_pool_size: 5,
  default_pool_max_overflow: 10,
  event_handlers: [
    {KafkaConsumer.TestEventHandler, [{"topic", 0}, {"topic2", 0}], size: 5, max_overflow: 5}
  ]
```

* Start your app.

## Configuration

`event_handlers` key in configuration accepts list of tuples `{handler_module, topics, opts}`, where you can omit options parameter and worker use default values (acceptable for pool size and max_overflow).
