defmodule Rwife.Workers.MonitoredProcess do
  @type t :: %__MODULE__{}

  defstruct [:worker_info, :kill_method, limits: []]

  def os_pid(mp) do
    mp.worker_info.os_pid
  end

  def worker_info(mp) do
    mp.worker_info
  end
end
