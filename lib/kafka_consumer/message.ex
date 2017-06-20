defmodule KafkaConsumer.Message do
  defstruct [:topic, :partition, :offset, :magic_byte, :attributes, :key, :value, :crc]

  def make(topic, partition, {:kafka_message, offset, magic_byte, attributes, key, value, crc}) do
    %__MODULE__{
      topic: topic, partition: partition,
      offset: offset, magic_byte: magic_byte,
      attributes: attributes, key: key,
      value: value, crc: crc}
  end
end
