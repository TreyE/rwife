defmodule Rwife.Workers.MonitorState do
  defstruct [monitored_processes: [], perf_readings: [], keep_since: nil]
end
