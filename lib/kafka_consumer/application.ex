defmodule KafkaConsumer.Application do
  use Application

  def start(_type, _args) do
    {:ok, _pid} = KafkaConsumer.ConsumerSup.start_link
  end
end
