defmodule Rwife.Workers.PerfReading do
  @type t :: %__MODULE__{}
  @type readings_list :: [%__MODULE__{}]

  defstruct [:os_pid,:vss, :rss, :cpu_percent, :timestamp]

  @spec new(number(), number(), number(), any(), any()) :: Rwife.Workers.PerfReading.t()
  def new(os_p, vss_val, rss_val, cpu_p_val, ts_val) do
     %Rwife.Workers.PerfReading{} |>
       os_pid(os_p) |>
       vss(vss_val) |>
       rss(rss_val) |>
       cpu_percent(cpu_p_val) |>
       timestamp(ts_val)
  end

  defp os_pid(pr, os_p) when is_number(os_p) do
    %Rwife.Workers.PerfReading{pr | os_pid: os_p}
  end

  defp vss(pr, vss_val) when is_number(vss_val) do
    %Rwife.Workers.PerfReading{pr | vss: vss_val}
  end

  defp rss(pr, rss_val) when is_number(rss_val) do
    %Rwife.Workers.PerfReading{pr | rss: rss_val}
  end

  defp cpu_percent(pr, cpu_p) do
    %Rwife.Workers.PerfReading{pr | cpu_percent: cpu_p}
  end

  defp timestamp(pr, ts_val) do
    %Rwife.Workers.PerfReading{pr | timestamp: ts_val}
  end
end
