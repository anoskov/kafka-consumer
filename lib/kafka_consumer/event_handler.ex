defmodule KafkaConsumer.EventHandler do
  use Behaviour

  @doc """
  Handle event from topic
  """
  @callback handle_event(pid, {String.t, number, Map.t}) :: {atom, Map.t}
end
