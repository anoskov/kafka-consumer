defmodule KafkaConsumer.ReleaseTasks do
  @client :kafka_client

  def check do
    Application.load(:brod)

    clients = get_clients()
    endpoints = get_endpoints(clients)
    topics = get_topics()

    with :ok <- do_check_connection(endpoints, nil),
         :ok <- do_check_topics(endpoints, topics, nil)
    do
      :ok
    end
  end

  def check_connection do
    Application.load(:brod)

    clients = get_clients()
    endpoints = get_endpoints(clients)

    do_check_connection(endpoints, nil)
  end

  defp get_clients do
    Application.fetch_env!(:brod, :clients)
  end

  defp get_endpoints(clients) do
    clients
    |> Keyword.fetch!(@client)
    |> Keyword.fetch!(:endpoints)
  end

  defp get_topics do
    consumers = Application.get_env(:kafka_consumer, :consumers, [])

    consumers
    |> Enum.reduce([], fn(consumer, acc) ->
         acc ++ Keyword.get(consumer, :topics, [])
       end)
    |> Enum.uniq()
  end

  defp do_check_connection(_endpoints, _error, tries \\ 10)
  defp do_check_connection(_endpoints, error, tries) when tries <= 0 do
    error
  end
  defp do_check_connection(endpoints, _error, tries) do
    case :brod_utils.try_connect(endpoints) do
      {:ok, _sock} ->
        :ok
      error ->
        :timer.sleep(2000)
        do_check_connection(endpoints, error, tries - 1)
    end
  end

  defp do_check_topics(_endpoints, _topics, _error, tries \\ 20)
  defp do_check_topics(_endpoints, _topics, error, tries) when tries <= 0 do
    error
  end
  defp do_check_topics(endpoints, topics, _error, tries) do
    with {:ok, _apps} <- Application.ensure_all_started(:brod),
         :ok <- get_metadata(topics)
    do
      :ok
    else
      error ->
        :timer.sleep(2000)
        do_check_topics(endpoints, topics, error, tries - 1)
    end
  end

  defp get_metadata(topics) do
    Enum.reduce(topics, :ok, fn
      (_topic, {:error, reason}) ->
        {:error, reason}
      (topic, :ok) ->
        case :brod.get_partitions_count(@client, topic) do
          {:ok, prts} when prts >= 1 ->
            :ok
          {:ok, _prts} ->
            {:error, :no_partitions}
          {:error, reason} ->
            {:error, reason}
        end
      end)
  end
end
