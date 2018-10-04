defmodule Rwife.PsAdapters.OsxAdapter do
  @behaviour Rwife.PsAdapter

  @spec encode_command([integer() | String.t]) :: String.t
  def encode_command([]) do
   "ps -x -o \"pid=,vsz=,rss=,pcpu=\" -www"
  end

  def encode_command(os_pids) do
    pid_list = Enum.join(os_pids, ",")
   "ps -x -o \"pid=,vsz=,rss=,pcpu=\" -www -p #{pid_list}"
  end

  @spec parse_ps_output(any, String.t) :: Rwife.Workers.PerfReading.readings_list
  def parse_ps_output(timestamp, resp) do
    lines = String.split(resp, ~r{\n}, [trim: true])
    Enum.map(lines, fn(line) ->
      parts = String.split(line, ~r{\s+}, [trim: true])
      Rwife.Workers.PerfReading.new(
        cast_pid(Enum.fetch!(parts, 0)),
        cast_mem_size(Enum.fetch!(parts, 1)),
        cast_mem_size(Enum.fetch!(parts, 2)),
        Enum.fetch!(parts, 3),
        timestamp
      )
    end)
  end

  defp cast_pid(pid_val) when is_number(pid_val) do
    pid_val
  end

  defp cast_pid(pid_val) when is_binary(pid_val) do
    case Integer.parse(pid_val) do
      {int, _} -> int
      :error -> 0
    end
  end

  defp cast_mem_size(mem_val) when is_number(mem_val) do
    mem_val * 1024
  end

  defp cast_mem_size(mem_val) when is_binary(mem_val) do
    case Integer.parse(mem_val) do
      {int, _} -> int * 1024
      :error -> 0
    end
  end
end
