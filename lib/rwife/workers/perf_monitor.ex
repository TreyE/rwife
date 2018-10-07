defmodule Rwife.Workers.PerfMonitor do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: get_local_name())
  end

  def get_local_name() do
    __MODULE__
  end

  @spec init(any()) :: {:ok, Rwife.Workers.MonitorState.t()}
  def init(_) do
    Process.flag(:trap_exit, true)
    {:ok, Rwife.Workers.MonitorState.new()}
  end

  @spec watch(Rwife.Workers.MonitoredProcess.t()) :: any()
  def watch(mp) do
    GenServer.call(get_local_name(), {:watch, mp})
  end

  def handle_call({:watch, mp}, _from, state) do
    Process.link(mp.port)
    new_state = Rwife.Workers.MonitorState.add_monitored_process(state, mp)
    Process.link(mp.port)
    Process.send_after(self(), :tick, 2500)
    {:reply, :ok, new_state}
  end

  def handle_info(:tick, state) do
    case Rwife.Workers.MonitorState.due_for_check_as_of(state) do
      :now ->
        new_state = perf_check_loop(state)
        Process.send_after(self(), :tick, 2000)
        {:noreply, new_state}
      val ->
        Process.send_after(self(), :tick, val)
        {:noreply, state}
    end
  end

  def handle_info({:EXIT, err_port, _}, state)
     when is_port(err_port) do
     {:noreply, Rwife.Workers.MonitorState.remove_port(state, err_port)}
  end

  def handle_info({err_port, {:exit_status, _}}, state)
     when is_port(err_port) do
     {:noreply, Rwife.Workers.MonitorState.remove_port(state, err_port)}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  @spec perf_check_loop(Rwife.Workers.MonitorState.t()) :: Rwife.Workers.MonitorState.t()
  defp perf_check_loop(state) do
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
        %Rwife.Settings.KillMethod{} = km -> Kernel.spawn(fn() -> Rwife.Settings.KillMethod.execute_kill(km, mp) end)
        _ -> :ok
      end
    end)
  end
end
