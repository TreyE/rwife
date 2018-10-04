defmodule Rwife.Settings.Limits.MemoryIntervalLimit do
  @type t :: %__MODULE__{
    per: integer(),
    times: integer(),
    every: integer()
  }

  defstruct [per: 5, times: 3, every: 30000, limit: nil]

  def max_interval(mil) do
    (mil.every * mil.per) + mil.every
  end

  def hit?(mil, readings, last_update) do
    limit_time = (last_update - (max_interval(mil)/1000))
    selected_readings = Enum.filter(readings, fn(reading) ->
      reading.timestamp >= limit_time
    end)
    case has_min_measurements?(mil, selected_readings) do
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
    (Enum.count(readings) >= mil.per)
  end
end
