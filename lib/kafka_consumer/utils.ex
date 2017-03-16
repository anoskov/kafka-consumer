defmodule KafkaConsumer.Utils do
  alias KafkaConsumer.Server
  import Supervisor.Spec, only: [worker: 3]

  @type gproc_name :: {atom, atom, {atom, atom, {atom, String.t}}}

  @doc """
  Check topic in Kafka
  """
  @spec topic_exists?(String.t, non_neg_integer) :: boolean
  def topic_exists?(topic, partition) do
    KafkaEx.latest_offset(topic, partition) != :topic_not_found
  end

  @doc """
  Stop stream worker if it alredy exists or start it if not
  """
  @spec prepare_stream(atom) :: atom
  def prepare_stream(worker_name) do
    KafkaEx.create_worker(worker_name)
    :ok
  end

  @doc """
  Stop stream and unreg process in gproc
  """
  @spec stop_stream(atom) :: atom
  def stop_stream(worker_name) do
    KafkaEx.stop_streaming(worker_name: worker_name)
    :ok
  end

  @doc """
  Returns event handlers spec from KafkaConsumer config
  """
  @spec event_handlers_spec :: [Supervisor.Spec.spec]
  def event_handlers_spec do
    childs = Enum.map(event_handlers(), &event_handler_spec/1)

    childs
    |> List.flatten
    |> Enum.uniq
  end

  @doc """
  Creates name for KafkaEx streaming worker process
  """
  @spec worker_name(String.t, String.t) :: atom
  def worker_name(topic, partition) do
    [topic, partition, "stream"] |> Enum.join("$") |> String.to_atom
  end

  @doc """
  Creates unique name for server process based on topic and partition
  """
  @spec consumer_name(String.t, non_neg_integer) :: gproc_name
  def consumer_name(topic, partition) do
    [topic, partition] |> Enum.join("$") |> via_tuple
  end

  ### Internal functions

  @spec via_tuple(String.t) :: gproc_name
  defp via_tuple(worker_name) do
    {:via, :gproc, {:n, :l, {:consumer, worker_name}}}
  end

  def supervisor_worker_id(topic, partition) do
    [topic, partition] |> Enum.join("$") |> String.to_atom
  end

  # defp event_handler_spec({topic, partition, handler, handler_pool, size, max_overflow}) do
  defp event_handler_spec({handler, topics, opts}) do
    size = Keyword.get(opts, :size, default_pool_size())
    max_overflow = Keyword.get(opts, :max_overflow, default_pool_max_overflow())

    pool = poolboy_spec(handler, handler, size, max_overflow)
    handlers = Enum.map(topics, fn({topic, partition}) ->
      worker(Server,
        [%KafkaConsumer.Settings{topic: topic,
                                 partition: partition,
                                 handler: handler,
                                 handler_pool: handler}],
        [id: supervisor_worker_id(topic, partition)])
    end)

    [pool, handlers]
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

  defp event_handlers do
    Application.get_env(:kafka_consumer, :event_handlers)
  end

  defp default_pool_size do
    Application.get_env(:kafka_consumer, :default_pool_size)
  end

  defp default_pool_max_overflow do
    Application.get_env(:kafka_consumer, :default_pool_max_overflow)
  end
end
