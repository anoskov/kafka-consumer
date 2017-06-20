defmodule KafkaConsumer.ConsumerTest do
  use ExUnit.Case

  defmodule ConsumerAsync do
    use KafkaConsumer.Consumer

    def handle_async(%{key: "error"} = message) do
      exit(message.value)
    end
    def handle_async(_) do
      :ok
    end
  end

  defmodule ConsumerSync do
    use KafkaConsumer.Consumer

    def handle_sync(%{key: "error"} = message, _state) do
      exit(message.value)
    end
    def handle_sync(_, state) do
      {:ok, :ack, state}
    end
  end

  setup do
    {:ok, _} = KafkaConsumer.Supervisor.start_link()
    :ok
  end

  describe "async consumer" do
    test "don't crash if there's error in consumer handler" do
      message = {:kafka_message, 6, 0, 0, "error", "what", 1001589737}

      assert {:ok, :ack, %{}} == ConsumerAsync.handle_message("topic", 0, message, %{})
    end
  end

  describe "sync consumer" do
    test "crash if there's error in consumer handler" do
      message = {:kafka_message, 6, 0, 0, "error", "what", 1001589737}

      assert catch_exit(ConsumerSync.handle_message("topic", 0, message, %{}))
    end
  end
end
