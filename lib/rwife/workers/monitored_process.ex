defmodule Rwife.Workers.MonitoredProcess do
  @type t :: %__MODULE__{}

  defstruct [:os_pid, :kill_method, limits: []]
end
