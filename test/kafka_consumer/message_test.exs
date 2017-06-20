defmodule KafkaConsumer.MessageTest do
  use ExUnit.Case

  alias KafkaConsumer.Message

  test "#make" do
    kafka_message = {:kafka_message, 6, 0, 0, "", "what", 1001589737}

    assert %KafkaConsumer.Message{attributes: 0, crc: 1001589737, key: "",
                             magic_byte: 0, offset: 6, partition: 42, topic: "topic",
                             value: "what"}
        == Message.make("topic", 42, kafka_message)
  end
end
