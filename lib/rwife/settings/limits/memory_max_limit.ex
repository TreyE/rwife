defmodule Rwife.Settings.Limits.MemoryMaxLimit do
  @type t :: %__MODULE__{}

  defstruct [limit: nil]

  def max_interval(_) do
    10000
  end

  def hit?(_, []) do
    false
  end

  def hit?(mil, readings) do
    Enum.any?(readings, fn(reading) ->
      reading.rss >= mil.limit
    end)
  end
end
