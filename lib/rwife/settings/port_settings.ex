defmodule Rwife.Settings.PortSettings do
  @type t :: %__MODULE__{}

  defstruct [command: nil, timeout: 30000, spawn_args: []]
end
