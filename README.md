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
config :kafka_consumer,
  kafka_host: "localhost",
  consumer_group: "kafka_ex" ,
  sync_timeout: 3000,
  max_restarts: 10,
  max_seconds: 60
```

* Add event handler pool/pools to your Supervisor
```elixir
poolboy_config = [
  {:name, {:local, :test_event_handler_pool}},
  {:worker_module, KafkaConsumer.TestEventHandler},
  {:size, 5},
  {:max_overflow, 5}
]
children = [:poolboy.child_spec(:event_handler_pool, poolboy_config, [])]
supervise(children, strategy: :one_for_one)
```

* Write your own EventHandler
```elixir
defmodule EventHandler do
  @behaviour KafkaConsumer.EventHandler
  use GenServer
  require Logger

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], [])
  end

  def handle_event(pid, data) do
    GenServer.cast(pid, data)
  end

  def handle_cast({topic, _partition, message}, state) do
    Logger.debug "from #{topic} message: #{inspect message}"
    {:noreply, state}
  end
end
```

* Set settings for consumer
```elixir
settings = %KafkaConsumer.Settings{topic: "topic",
 partition: 0,
 handler: TestEventHandler,
 handler_pool: :test_event_handler_pool
}
```

* Start your event handler pool
```elixir
TestEventHandlerSup.start_link
```

* Start consumer
```elixir
KafkaConsumer.start_link(settings)
```
