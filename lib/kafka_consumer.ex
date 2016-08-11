defmodule KafkaConsumer do
  use Application
  import Supervisor.Spec, only: [worker: 3]
  alias KafkaConsumer.{Server, Utils}

  defmodule Settings do
    defstruct topic: nil, partition: 0, handler: nil, handler_pool: nil
  end

  @type settings :: %Settings{
    topic: String.t | nil,
    partition: non_neg_integer(),
    handler: atom(),
    handler_pool: atom()
  }

  def start(_type, _args) do
    children = event_handlers_spec(event_handlers)

    opts = [strategy: :one_for_one, name: KafkaConsumer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp event_handlers do
    Application.get_env(:kafka_consumer, :event_handlers)
  end

  defp event_handlers_spec(event_handlers) do
    childs = Enum.map(event_handlers, fn {topic, partition, handler, handler_pool,
      size, max_overflow} ->
        pool = poolboy_spec(handler_pool, handler, size, max_overflow)
        worker = worker(Server,
          [%KafkaConsumer.Settings{topic: topic,
              partition: partition,
              handler: handler,
              handler_pool: handler_pool}],
          [id: [topic, partition] |> Enum.join("$") |> String.to_atom])
        [pool, worker]
    end)

    childs
    |> List.flatten
    |> Enum.uniq
  end

  defp poolboy_spec(name, handler, size, max_overflow) do
    poolboy_config = [
      {:name, {:local, name}},
      {:worker_module, handler},
      {:size, size},
      {:max_overflow, max_overflow}
    ]

    :poolboy.child_spec(name, poolboy_config, [])
  end
end
