defmodule Rwife.Settings.PerfLimit do
  @type t :: %__MODULE__{
    kill_method: Rwife.Settings.KillMethod.t(),
    limits: [limit_type()]
  }

  @type limit_type :: Rwife.Settings.Limits.MemoryIntervalLimit.t() | Rwife.Settings.Limits.MemoryMaxLimit.t()

  defstruct [kill_method: nil, limits: []]

  @spec new([limit_type]) :: Rwife.Settings.PerfLimit.t()
  def new(limits) when is_list(limits) do
    %__MODULE__{
      kill_method: Rwife.Settings.KillMethod.new(),
      limits: limits
    }
  end

  @spec new(Rwife.Settings.KillMethod.kill_signal(), [limit_type]) :: Rwife.Settings.PerfLimit.t()
  def new(stop_sig, limits) when is_list(limits) do
    %__MODULE__{
      kill_method: Rwife.Settings.KillMethod.new(stop_sig),
      limits: limits
    }
  end

  @spec new(Rwife.Settings.KillMethod.kill_signal(), integer(), [limit_type]) :: Rwife.Settings.PerfLimit.t()
  def new(stop_sig, k_wait, limits) when is_list(limits) and is_integer(k_wait) do
    %__MODULE__{
      kill_method: Rwife.Settings.KillMethod.new(stop_sig, k_wait),
      limits: limits
    }
  end

  def max_memory_limit(val) do
    %Rwife.Settings.Limits.MemoryMaxLimit{limit: mem_size(val)}
  end

  def memory_interval_limit(mem, times, per, every) do
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
