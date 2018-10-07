defmodule Rwife.Workers.MonitorState do
  @type t :: %__MODULE__{
    monitored_processes: [Rwife.Workers.MonitoredProcess.t],
    perf_readings: RWife.Workers.PerfReadings.readings_list,
    longest_interval: integer(),
    last_update: integer()
  }

  defstruct [monitored_processes: [], perf_readings: [], longest_interval: 0, last_update: nil]

  @spec new() :: Rwife.Workers.MonitorState.t()
  def new() do
    %Rwife.Workers.MonitorState{last_update: System.os_time(:second)}
  end

  @spec add_monitored_process(
          Rwife.Workers.MonitorState.t(),
          RWife.Workers.MonitoredProcess.t()
        ) :: Rwife.Workers.MonitorState.t()
  def add_monitored_process(ms, mp) do
    %Rwife.Workers.MonitorState{ms | monitored_processes: [mp|ms.monitored_processes]}
  end

  @spec update_readings(Rwife.Workers.MonitorState.t()) :: Rwife.Workers.MonitorState.t()
  def update_readings(%__MODULE__{monitored_processes: []} = ms) do
    ms
  end

  def update_readings(ms) do
    pids = Enum.map(ms.monitored_processes, fn(mp) ->
      mp.os_pid
    end)
    new_readings = Rwife.PsAdapter.take_measurements(Enum.to_list(pids))
    last_update = System.os_time(:millisecond)
    earliest_time = last_update - ms.longest_interval
    kept_readings = Enum.reject(ms.perf_readings, fn(pr) ->
      pr.timestamp < earliest_time
    end)
    all_readings = kept_readings ++ new_readings
    %__MODULE__{ms | perf_readings: all_readings, last_update: last_update}
  end

  @spec past_limit_pids(Rwife.Workers.MonitorState.t()) :: [integer()]
  def past_limit_pids(%__MODULE__{monitored_processes: []}) do
    []
  end

  def past_limit_pids(ms) do
    proc_hash = Enum.group_by(ms.monitored_processes, fn(mp) ->
      mp.os_pid
    end)
    readings_hash = Enum.group_by(ms.perf_readings, fn(pr) ->
      pr.os_pid
    end)
    os_pids = Map.keys(proc_hash)
    Enum.filter(os_pids, fn(os_pid) ->
      [mp] = Map.fetch!(proc_hash, os_pid)
      limits = mp.limits
      p_readings = Map.get(readings_hash, os_pid, [])
      case limits do
        [] -> false
        _ -> check_limits(limits, p_readings, ms.last_update)
      end
    end)
  end

  @spec remove_port(Rwife.Workers.MonitorState.t(), port()) :: Rwife.Workers.MonitorState.t()
  def remove_port(ms, removed_port) when is_port(removed_port) do
    kept_mps = Enum.reject(ms.monitored_processes, fn(mp) ->
      mp.port == removed_port
    end)
    %__MODULE__{ms | monitored_processes: kept_mps}
  end

  @spec remove_pids(Rwife.Workers.MonitorState.t(), [integer()]) :: Rwife.Workers.MonitorState.t()
  def remove_pids(ms, []) do
    ms
  end

  def remove_pids(ms, os_pid_list) do
    kept_mps = Enum.reject(ms.monitored_processes, fn(mp) ->
      Enum.member?(os_pid_list, mp.os_pid)
    end)
    kept_prs = Enum.reject(ms.perf_readings, fn(pr) ->
      Enum.member?(os_pid_list, pr.os_pid)
    end)
    new_longest_interval = Enum.max(Enum.flat_map(kept_mps, &limit_times/1), fn() -> 0 end)
    %__MODULE__{ms | monitored_processes: kept_mps, perf_readings: kept_prs, longest_interval: new_longest_interval}
  end
  def select_monitored_processes_by_os_pid(ms, os_pid_list) do
    Enum.filter(ms.monitored_processes, fn(mp) ->
      Enum.member?(os_pid_list, mp.os_pid)
    end)
  end

  def due_for_check_as_of(ms) do
    now = System.os_time(:millisecond)
    diff = (now - ms.last_update)
    case (diff >= 2400) do
      false -> (2400 - diff)
      true -> :now
    end
  end

  defp check_limits(limits, p_readings, last_update) do
    Enum.any?(limits, fn(limit) ->
      check_limit(limit, p_readings, last_update)
    end)
  end

  defp check_limit(_, _, nil) do
    false
  end

  defp check_limit(%Rwife.Settings.Limits.MemoryIntervalLimit{} = limit, p_readings, last_update) do
    Rwife.Settings.Limits.MemoryIntervalLimit.hit?(limit, p_readings, last_update)
  end

  defp check_limit(%Rwife.Settings.Limits.MemoryMaxLimit{} = limit, p_readings, last_update) do
    Rwife.Settings.Limits.MemoryMaxLimit.hit?(limit, p_readings, last_update)
  end

  defp limit_times(mp) do
    Enum.map(mp.limits, &get_limit_interval/1)
  end

  defp get_limit_interval(%Rwife.Settings.Limits.MemoryIntervalLimit{} = limit) do
    Rwife.Settings.Limits.MemoryIntervalLimit.max_interval(limit)
  end

  defp get_limit_interval(%Rwife.Settings.Limits.MemoryMaxLimit{} = limit) do
    Rwife.Settings.Limits.MemoryMaxLimit.max_interval(limit)
  end
end
