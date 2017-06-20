defmodule KafkaConsumer.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    supervise(supervisor_childs(),
      strategy: :one_for_one, max_restarts: max_restarts(), max_seconds: max_seconds())
  end

  defp supervisor_childs do
    [task_supervisor() | KafkaConsumer.Spec.consumer_workers()]
  end

  defp task_supervisor do
    supervisor(Task.Supervisor, [[name: KafkaConsumer.TaskSupervisor, restart: task_restart()]])
  end

  defp task_restart do
    Application.get_env(:kafka_consumer, :task_restart, :temporary)
  end

  defp max_restarts do
    Application.get_env(:kafka_consumer, :max_restarts, 3)
  end

  defp max_seconds do
    Application.get_env(:kafka_consumer, :max_seconds, 5)
  end
end
