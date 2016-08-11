defmodule KafkaConsumer.Utils do

  @doc """
    Check topic in Kafka
  """
  @spec topic_exists?(String.t, Integer.t) :: boolean
  def topic_exists?(topic, partition) do
    if KafkaEx.latest_offset(topic, partition) == :topic_not_found do
      false
    else
      true
    end
  end

  @doc """
    Stop stream worker if it alredy exists or start it if not
  """
  @spec prepare_stream(atom) :: atom
  def prepare_stream(worker_name) do
    if Process.whereis(worker_name) do
      KafkaEx.stop_streaming(worker_name: worker_name)
    else
      KafkaEx.create_worker(worker_name)
    end
    :ok
  end

  @doc """
    Stop stream
  """
  @spec stop_stream(atom) :: atom
  def stop_stream(worker_name) do
    if Process.whereis(worker_name), do: KafkaEx.stop_streaming(worker_name: worker_name)
    :ok
  end

end
