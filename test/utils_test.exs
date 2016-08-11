defmodule KafkaConsumer.UtilsTest do
  use ExUnit.Case, async: false
  alias KafkaConsumer.{Utils}
  import Mock

  test_with_mock "topic_exists? return false if topic not found", KafkaEx,
      [latest_offset: fn(_topic, _partition) -> :topic_not_found end] do
    assert Utils.topic_exists?("topic", 0) == false
  end

  test_with_mock "topic_exists? return true if topic exists", KafkaEx,
      [latest_offset: fn(_topic, _partition) -> :ok end] do
    assert Utils.topic_exists?("topic", 0) == true
  end

  test "prepare stream create worker process if it not already started" do
    Utils.prepare_stream(:"topic$0$stream")
    assert Process.whereis(:"topic$0$stream")
  end
end
