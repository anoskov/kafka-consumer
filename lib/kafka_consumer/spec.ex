defmodule KafkaConsumer.Spec do
  import Supervisor.Spec

  def consumer_workers(config \\ consumers_config()) do
    validate_consumer_ids(config)

    Enum.map(config, fn(consumer) ->
      worker(:brod_group_subscriber, consumer_args(consumer), id: consumer_id(consumer))
    end)
  end

  defp consumer_args(opts) do
    client = Keyword.fetch!(opts, :client)
    group_id = Keyword.fetch!(opts, :group_id)
    topics = Keyword.fetch!(opts, :topics)
    callback = Keyword.fetch!(opts, :callback)
    callback_args = Keyword.get(opts, :callback_args, [])

    # https://github.com/klarna/brod/blob/be2362f/src/brod_group_coordinator.erl#L152
    group_config = Keyword.get(opts, :group_config, [])
    # https://github.com/klarna/brod/blob/be2362f/src/brod_consumer.erl#L104
    consumer_config = Keyword.get(opts, :consumer_config, [])

    [client, group_id, topics, group_config, consumer_config, callback, callback_args]
  end

  defp validate_consumer_ids(config) when length(config) >= 2 do
    ids =
      Enum.map(config, fn(consumer) ->
        case Keyword.fetch(consumer, :id) do
          :error ->
            raise ArgumentError,
              "please specify :id param in consumers config, " <>
              "when using more than one consumer."
          {:ok, id} ->
            id
        end
      end)

    if length(ids) == length(Enum.uniq(ids)) do
      :ok
    else
      raise ArgumentError, ":id should be unique in consumers config"
    end
  end
  defp validate_consumer_ids(_) do
    :ok
  end

  defp consumer_id(opts) do
    Keyword.fetch!(opts, :group_id)
  end

  defp consumers_config do
    Application.get_env(:kafka_consumer, :consumers, [])
  end
end
