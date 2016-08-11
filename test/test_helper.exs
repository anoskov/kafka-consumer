ExUnit.start()

defmodule KafkaConsumer.TestEventHandlerSup do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    poolboy_config = [
      {:name, {:local, :test_event_handler_pool}},
      {:worker_module, KafkaConsumer.TestEventHandler},
      {:size, 5},
      {:max_overflow, 5}
    ]
    children = [:poolboy.child_spec(:event_handler_pool, poolboy_config, [])]
    supervise(children, strategy: :one_for_one)
  end
end

defmodule KafkaConsumer.TestEventHandler do
  @behaviour KafkaConsumer.EventHandler
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], [])
  end

  def handle_event(pid, data) do
    GenServer.cast(pid, data)
  end

  def handle_cast({_topic, _partition, _message}, state) do
    {:noreply, state}
  end
end
