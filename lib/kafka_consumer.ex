defmodule KafkaConsumer do
  use Application
  alias KafkaConsumer.Utils

  defmodule Settings do
    defstruct topic: nil, partition: 0, handler: nil, handler_pool: nil
  end

  @type settings :: %Settings{
    topic: String.t | nil,
    partition: non_neg_integer,
    handler: atom,
    handler_pool: atom
  }

  ### Application callbacks

  def start(_type, _args) do
    children = Utils.event_handlers_spec

    opts = [strategy: :one_for_one, name: KafkaConsumer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
