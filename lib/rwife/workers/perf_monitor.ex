defmodule Rwife.Workers.PerfMonitor do

  @spec perf_check_loop(Rwife.Workers.MonitorState.t()) :: Rwife.Workers.MonitorState.t()
  def perf_check_loop(state) do
    with_up_to_date_readings = state |> Rwife.Workers.MonitorState.update_readings
    killable_pids = Rwife.Workers.MonitorState.past_limit_pids(with_up_to_date_readings)
    run_pid_kills(with_up_to_date_readings, killable_pids)
    Rwife.Workers.MonitorState.remove_pids(with_up_to_date_readings, killable_pids)
  end

  defp run_pid_kills(_, []) do
  end

  defp run_pid_kills(state, os_pid_list) do
    mps = Rwife.Workers.MonitorState.select_monitored_processes_by_os_pid(state, os_pid_list)
    Enum.map(mps, fn(mp) ->
      case mp.kill_method do
        %Rwife.Settings.KillMethod{} = km -> Kernel.spawn(fn() -> Rwife.Settings.KillMethod.execute_kill(km, mp.worker_info) end)
        _ -> :ok
      end
    end)
  end
end
