defmodule KafkaConsumer.SpecTest do
  use ExUnit.Case

  alias KafkaConsumer.Spec

  describe "#consumer_workers" do
    test "makes valid args for worker" do
      config = [
        [client: :kafka_client,
         group_id: "kafka_consumer",
         topics: ["admin-events", "system-events"],
         callback: KafkaConsumer.ExampleConsumer,
         callback_args: []]
      ]

      [{_, {:brod_group_subscriber, :start_link, args}, _, _, _, _}] = Spec.consumer_workers(config)

      assert [:kafka_client, "kafka_consumer",
              ["admin-events", "system-events"], [], [],
              KafkaConsumer.ExampleConsumer, []]
          == args
    end

    test "throws error when there's more than once consumers without id" do
      config = [
        [client: :kafka_client_1,
         group_id: "kafka_consumer", topics: ["1"],
         callback: KafkaConsumer.ExampleConsumer],
        [client: :kafka_client_1,
         group_id: "kafka_consumer", topics: ["2"],
         callback: KafkaConsumer.ExampleConsumer]
      ]

      message = "please specify :id param in consumers config, when using more than one consumer."

      assert_raise(ArgumentError, message, fn ->
        Spec.consumer_workers(config)
      end)
    end

    test "throws error when there's more than once consumers with equal id" do
      config = [
        [id: :same, client: :kafka_client_1,
         group_id: "kafka_consumer", topics: ["1"],
         callback: KafkaConsumer.ExampleConsumer],
        [id: :same, client: :kafka_client_1,
         group_id: "kafka_consumer", topics: ["2"],
         callback: KafkaConsumer.ExampleConsumer]
      ]

      message = ":id should be unique in consumers config"

      assert_raise(ArgumentError, message, fn ->
        Spec.consumer_workers(config)
      end)
    end
  end
end
