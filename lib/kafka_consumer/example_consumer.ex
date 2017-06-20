defmodule KafkaConsumer.ExampleConsumer do
  use KafkaConsumer.Consumer

  def handle_async(_message) do
    :ok
  end
end
