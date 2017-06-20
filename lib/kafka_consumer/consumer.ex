defmodule KafkaConsumer.Consumer do
  @type state   :: term
  @type message :: %KafkaConsumer.Message{}

  @callback handle_sync(message, state) :: {:ok, state} | {:ok, :ack, state}
  @callback handle_async(message) :: any

  @optional_callbacks handle_sync: 2, handle_async: 1

  defmacro __using__(_opts) do
    quote do
      require Logger

      import KafkaConsumer.Message

      @behaviour KafkaConsumer.Consumer
      @behaviour :brod_group_subscriber

      def init(_group_id, _init_args) do
        {:ok, []}
      end

      def handle_message(topic, partition, kafka_message, state) do
        __MODULE__.handle_sync(KafkaConsumer.Message.make(topic, partition, kafka_message), state)
      end

      def handle_sync(message, state) do
        Task.Supervisor.start_child(KafkaConsumer.TaskSupervisor, fn ->
          __MODULE__.handle_async(message)
        end)

        {:ok, :ack, state}
      end

      def handle_async(message) do
        :ok
      end

      defoverridable init: 2, handle_sync: 2, handle_async: 1
    end
  end
end
