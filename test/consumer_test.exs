defmodule KafkaConsumer.ConsumerTest do
  use ExUnit.Case, async: false
  alias KafkaConsumer.{Utils, Settings, TestEventHandlerSup}

  test "consumer started if settings valid" do
    {:ok, pid} = start_consumer

    assert Process.alive?(pid)
  end

  test "consumer stoping if consumer with the same topic/partition already start" do
    Process.flag(:trap_exit, true)
    start_consumer
    {:ok, pid} = KafkaConsumer.start_link(settings_template)
    :timer.sleep(200)

    assert Process.alive?(pid) == false
  end

  defp start_consumer do
    start_pool
    KafkaConsumer.start_link(settings_template)
  end

  defp start_pool do
    TestEventHandlerSup.start_link
  end

  defp settings_template do
    %Settings{topic: "topic",
     partition: 0,
     handler: KafkaConsumer.TestEventHandler,
     handler_pool: :test_event_handler_pool
   }
  end

end
