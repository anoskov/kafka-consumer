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
    KafkaEx.create_worker(worker_name)
    :ok
  end

  @doc """
    Stop stream and unreg process in gproc
  """
  @spec stop_stream(atom) :: atom
  def stop_stream(worker_name) do
    if stream_exists?(worker_name) do
      unreg_stream(worker_name)
      KafkaEx.stop_streaming(worker_name: worker_name)
    end
    :ok
  end

  @doc """
    Registry stream in gproc
  """
  @spec reg_stream(atom) :: pid
  def reg_stream(worker_name) do
    :gproc.reg({:n, :l, worker_name})
  end

  @doc """
    Unregistry stream in gproc
  """
  @spec unreg_stream(atom) :: pid
  def unreg_stream(worker_name) do
    :gproc.unreg({:n, :l, worker_name})
  end

  @doc """
    Check stream process in gproc
  """
  @spec stream_exists?(atom) :: boolean
  def stream_exists?(worker_name) do
    case :gproc.where({:n, :l, worker_name}) do
      :undefined ->
        false
      _pid ->
        true
    end
  end
end
