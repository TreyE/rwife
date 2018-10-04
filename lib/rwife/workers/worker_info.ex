defmodule Rwife.Workers.WorkerInfo do
  @type t :: %__MODULE__{}

  defstruct [os_pid: nil, pid: nil, port: nil, settings: []]

  def new(settings, port, pid, os_pid) do
    %__MODULE__{
      os_pid: os_pid,
      pid: pid,
      port: port,
      settings: settings
    }
  end

end
