defmodule KafkaConsumer.ConsumerTest do
  use ExUnit.Case, async: false

  alias KafkaConsumer.Supervisor, as: KafkaConsumerSupervisor
  alias KafkaConsumer.{Settings, Server, TestEventHandlerSup}

  test "starts consumer if settings valid" do
    {:ok, _} = start_pool
    {:ok, pid} = start_consumer

    assert Process.alive?(pid)
  end

  test "starts consumer workers from config topic$1" do
    result = Supervisor.which_children(KafkaConsumerSupervisor)
    child = Enum.find(result, fn({name, _pid, _type, _args}) ->
      name == :"topic$1"
    end)

    assert {_name, _pid, :worker, [Server]} = child
  end

  test "consumer stops when consumer with the same topic/partition already started" do
    Process.flag(:trap_exit, true)

    {:ok, _} = start_pool
    {:ok, _} = start_consumer

    result = start_consumer

    :timer.sleep(200)

    assert {:error, {:already_started, _}} = result
  end

  defp start_consumer do
    Server.start_link(settings_template)
  end

  defp start_pool do
    TestEventHandlerSup.start_link
  end

  defp settings_template do
    %Settings{topic: "topic",
              partition: 0,
              handler: KafkaConsumer.TestEventHandler,
              handler_pool: :test_event_handler_pool}
  end
end
