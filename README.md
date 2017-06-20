# Kafka consumer

Scalable consumer for Kafka using brod.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

* Add `kafka_consumer` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:kafka_consumer, "~> 2.0"}]
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
config :brod,
  clients: [
    kafka_client: [
      endpoints: [{'localhost', 9092}],
      auto_start_producers: true
    ]
  ]
```

* Write your own Consumer. Functions handle_async/1 and handle_sync/2 is overridable

```elixir
defmodule KafkaConsumer.ExampleConsumer do
  use KafkaConsumer.Consumer

  def handle_async(_message) do
    :ok
  end
end
```

* Set event handlers in config.

```elixir
config :kafka_consumer,
  consumers: [
    [client: :kafka_client,
     group_id: "messaging",
     topics: ["message-events", "system-events"],
     callback: KafkaConsumer.ExampleConsumer,
     callback_args: []]
  ]

```

* Define KafkaConsumer.Supervisor as child supervisor of your app.

```elixir
children = [
  supervisor(KafkaConsumer.Supervisor, []),
]
opts = [strategy: :one_for_one, name: YourApplication.Supervisor]
Supervisor.start_link(children, opts)
```

* Start your app.
