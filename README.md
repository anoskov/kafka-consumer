# Kafka consumer

Scalable consumer for Kafka using kafka_ex, poolboy and elixir.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

1. Add `kafka_consumer` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:kafka_consumer, github: "anoskov/kafka-consumer"}]
end
```

2. Ensure `kafka_consumer` is started before your application:

```elixir
def application do
  [applications: [:kafka_consumer]]
end
```

## Usage

1. Add event handler pool/pools to your Supervisor
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

2. Write your own EventHandler
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

3. Set settings for consumer
```elixir
settings = %KafkaConsumer.Settings{topic: "topic",
 partition: 0,
 handler: TestEventHandler,
 handler_pool: :test_event_handler_pool
}
```

4. Start your event handler pool
```elixir
TestEventHandlerSup.start_link
```

5. Start consumer
```elixir
KafkaConsumer.start_link(settings)
```
