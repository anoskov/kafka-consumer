# Kafka consumer

Consumer for Kafka using kafka_ex and elixir.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

1. Add `kafka_consumer` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:kafka_consumer, github: "anoskov/kafka-consumer"}]
end
```

2. Ensure `ccs_sdk` is started before your application:

```elixir
def application do
  [applications: [:kafka_consumer]]
end
```

## Usage
