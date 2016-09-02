defmodule KafkaConsumer.EventHandler do
  @type payload :: {String.t, number, map}

  @doc """
  Start Event Handler
  """
  @callback start_link(term) :: GenServer.on_start

  @doc """
  Handle event from topic
  """
  @callback handle_event(pid, payload) :: {atom, map}

  defmacro __using__(_) do
    quote do
      use GenServer

      @behaviour unquote(__MODULE__)

      def start_link(args) do
        GenServer.start_link(__MODULE__, args, [])
      end

      def handle_event(pid, payload) do
        GenServer.call(pid, payload)
      end

      defoverridable start_link: 1, handle_event: 2
    end
  end
end
