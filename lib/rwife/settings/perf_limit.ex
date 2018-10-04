defmodule Rwife.Settings.PerfLimit do
  def max_memory(val) do
    %Rwife.Settings.Limits.MemoryMaxLimit{limit: mem_size(val)}
  end

  def memory_interval(mem, times, per, every) do
    %Rwife.Settings.Limits.MemoryIntervalLimit{
      times: times,
      per: per,
      every: every,
      limit: mem_size(mem)
    }
  end

  defp mem_size({val, :megabytes}) when is_integer(val) do
    val * 1024 * 1024
  end

  defp mem_size(val) when is_integer(val) do
    val
  end
end
