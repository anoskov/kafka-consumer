defmodule KafkaConsumer.ConsumerSup do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    event_handlers = Application.get_env(:kafka_consumer, :event_handlers)
    childrens = build_childs(event_handlers)
    
    supervise(childrens, strategy: :one_for_one)
  end

  defp build_childs(event_handlers) do
    childs = Enum.map(event_handlers, fn {topic, partition, handler, handler_pool,
      size, max_overflow} ->
        pool = build_pool(handler_pool, handler, size, max_overflow)
        worker = worker(KafkaConsumer,
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

  defp build_pool(name, handler, size, max_overflow) do
      poolboy_config = [
        {:name, {:local, name}},
        {:worker_module, handler},
        {:size, size},
        {:max_overflow, max_overflow}
      ]
      :poolboy.child_spec(name, poolboy_config, [])
  end
end
