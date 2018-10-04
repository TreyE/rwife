defmodule Rwife.Settings.PortSettings do
  @type t :: %__MODULE__{}

  defstruct [command: nil, timeout: 30000, spawn_args: []]

  def new(cmd) do
    %__MODULE__{command: cmd}
  end

  def new(cmd, s_args) do
    %__MODULE__{command: cmd, spawn_args: s_args}
  end

  def new(cmd, s_args, t_out) do
    %__MODULE__{command: cmd, spawn_args: s_args, timeout: t_out}
  end
end
