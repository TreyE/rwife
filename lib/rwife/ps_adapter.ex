defmodule Rwife.PsAdapter do
  @callback encode_command([integer() | String.t()]) :: String.t()
  @callback parse_ps_output(any(), String.t()) :: Rwife.Workers.PerfReading.readings_list

  @spec take_measurements([integer() | String.t()]) :: Rwife.Workers.PerfReading.readings_list
  def take_measurements(pids) do
    adapter_mod =
      case :os.type() do
        {:unix, :darwin} -> Rwife.PsAdapters.OsxAdapter
        _ -> Rwife.PsAdapters.LinuxAdapter
      end
    cmd = adapter_mod.encode_command(pids)
    cmd_output = :os.cmd(to_charlist(cmd))
    adapter_mod.parse_ps_output(:os.timestamp(), to_string(cmd_output))
  end
end
