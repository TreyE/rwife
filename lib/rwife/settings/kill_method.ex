defmodule Rwife.Settings.KillMethod do
  @type t :: %__MODULE__{}

  defstruct [stop_signal: 15, wait: 5000]

  @spec execute_kill(Rwife.Settings.KillMethod.t, Rwife.Workers.WorkerInfo.t) :: :ok | {:error, any()}
  def execute_kill(kill_method, worker_info) do
    Process.flag(:trap_exit, true)
    Process.link(worker_info.port)
    :os.cmd(to_charlist("kill -#{kill_method.stop_signal} #{worker_info.os_pid}"))
    port = worker_info.port
    wait_time = kill_method.wait
    kill_result = receive do
      {:EXIT, ^port, _} -> :ok
    after
      wait_time -> hard_kill(port, worker_info.os_pid)
    end
    Process.flag(:trap_exit, false)
    kill_result
  end

  @spec new() :: Rwife.Settings.KillMethod.t()
  def new() do
    %__MODULE__{}
  end

  @spec new(:SIGHUP | :SIGINT | :SIGKILL | :SIGTERM | integer()) :: Rwife.Settings.KillMethod.t()
  def new(stop_signal) do
    %__MODULE__{} |> signal(stop_signal)
  end


  @spec new(:SIGHUP | :SIGINT | :SIGKILL | :SIGTERM | integer(), integer()) ::
          Rwife.Settings.KillMethod.t()
  def new(stop_signal, wait) when is_integer(wait) do
    %__MODULE__{} |> signal(stop_signal) |> wait(wait)
  end

  defp signal(km, :SIGINT) do
    %__MODULE__{km | stop_signal: 2}
  end

  defp signal(km, :SIGHUP) do
    %__MODULE__{km | stop_signal: 1}
  end

  defp signal(km, :SIGKILL) do
    %__MODULE__{km | stop_signal: 9}
  end

  defp signal(km, :SIGTERM) do
    %__MODULE__{km | stop_signal: 15}
  end

  defp signal(km, s_val) when is_integer(s_val) do
    %__MODULE__{km | stop_signal: s_val}
  end

  defp wait(km, w_val) do
    %__MODULE__{km | wait: (w_val * 1000)}
  end

  defp hard_kill(port, os_pid) do
    :os.cmd(to_charlist("kill -9 #{os_pid}"))
    receive do
      {:EXIT, ^port, _} -> :ok
    after
      10000 -> {:error, {:wont_die, port}}
    end
  end
end
