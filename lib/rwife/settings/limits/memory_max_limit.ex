defmodule Rwife.Settings.Limits.MemoryMaxLimit do
  @type t :: %__MODULE__{}

  defstruct [limit: nil]

  def max_interval(_) do
    20000
  end

  def hit?(_, [], _) do
    false
  end

  def hit?(mil, readings, _) do
    Enum.any?(readings, fn(reading) ->
      reading.rss >= mil.limit
    end)
  end
end
