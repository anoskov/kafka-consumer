defmodule KafkaConsumer.Server do
  use GenServer

  alias KafkaConsumer.Utils

  def start_link(%{topic: topic, partition: partition} = settings) do
    consumer_name = [topic, partition] |> Enum.join("$")
    GenServer.start_link(__MODULE__, settings, name: via_tuple(consumer_name))
  end

  ### GenServer Callbacks

  def init(%{topic: topic, partition: partition} = settings) do
    worker_name = [topic, partition, "stream"] |> Enum.join("$") |> String.to_atom
    send self(), {:consume, Map.put(settings, :worker_name, worker_name)}

    {:ok, %{topic: topic, partition: partition, worker_name: worker_name}}
  end

  def handle_info({:consume, settings}, state) do
    consumer_pid = self()

    spawn_link(fn -> consume(settings, consumer_pid) end)

    {:noreply, state}
  end

  def handle_info(:topic_not_found, state) do
    {:stop, :topic_not_found, state}
  end

  def terminate(:topic_not_found, _state) do
    :ok
  end

  def terminate(_reason, %{worker_name: worker_name} = _state) do
    Utils.stop_stream(worker_name)
    :ok
  end

  ### Internal Functions

  @doc """
  Consume messages from topic or stop consumer if topic not found
  """
  @spec consume(Map.t, pid) :: atom
  def consume(%{topic: topic, partition: partition, worker_name: worker_name,
      handler: handler, handler_pool: handler_pool}, consumer) do
    if Utils.topic_exists?(topic, partition) do
      Utils.prepare_stream(worker_name)
      for message <- KafkaEx.stream(topic, partition, worker_name: worker_name) do
        :poolboy.transaction(handler_pool, fn(pid) ->
          handler.handle_event(pid, {topic, partition, message})
        end)
      end
    else
      send consumer, :topic_not_found
    end
    :ok
  end

  @spec via_tuple(String.t) :: {atom, atom, {atom, atom, {atom, String.t}}}
  defp via_tuple(worker_name) do
    {:via, :gproc, {:n, :l, {:consumer, worker_name}}}
  end
end
