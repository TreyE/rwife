defmodule Rwife.Workers.MonitoredProcess do
  @type t :: %__MODULE__{
    os_pid: integer(),
    port: port(),
    kill_method: Rwife.Settings.KillMethod.t(),
    limits: [Rwife.Settings.PerfLimit.limit_type()]
  }

  defstruct [:os_pid, :port, :kill_method, limits: []]

  @spec new(integer(), port(), Rwife.Settings.PerfLimit.t()) :: Rwife.Workers.MonitoredProcess.t()
  def new(os_pid, port, %Rwife.Settings.PerfLimit{} = perf_limit) when
    is_integer(os_pid) and is_port(port) do
    %__MODULE__{
      os_pid: os_pid,
      port: port,
      kill_method: perf_limit.kill_method,
      limits: perf_limit.limits
    }
  end
end
