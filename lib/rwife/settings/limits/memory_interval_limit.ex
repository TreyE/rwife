defmodule Rwife.Settings.Limits.MemoryIntervalLimit do
  @type t :: %__MODULE__{}

  defstruct [per: 5, times: 3, every: 30000, limit: nil]

  def max_interval(mil) do
    mil.every * mil.per * 2
  end

  def hit?(mil, readings) do
    case has_min_measurements?(mil, readings) do
      true -> false
         _ -> over_ratio(mil, readings) >= ratio(mil)
    end
  end

  defp over_ratio(_, []) do
    0
  end

  defp over_ratio(mil, readings) do
    total_count = Enum.count(readings)
    over_count = Enum.count(readings, fn(reading) ->
      reading.rss >= mil.limit
    end)
    over_count / total_count
  end

  defp ratio(mil) do
    (mil.times / mil.per) - 0.01
  end

  defp has_min_measurements?(mil, readings) do
    (Enum.count(readings) > mil.per)
  end
end
