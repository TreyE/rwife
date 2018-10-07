defmodule Rwife.Settings.PortSettings do
  @type t :: %__MODULE__{
    command: String.t(),
    timeout: integer(),
    spawn_args: spawn_args_type,
    perf_limit: :LET_ME_BE | Rwife.Settings.PerfLimit.t
  }

  @type spawn_args_type :: [term]

  defstruct [command: nil, timeout: 30000, spawn_args: [], perf_limit: :LET_ME_BE]

  @spec new(String.t()) :: Rwife.Settings.PortSettings.t()
  def new(cmd) do
    %__MODULE__{command: cmd}
  end

  @spec new(String.t(), Rwife.Settings.PerfLimit.t() | spawn_args_type | integer()) :: Rwife.Settings.PortSettings.t()
  def new(cmd, %Rwife.Settings.PerfLimit{} = p_limit) do
    %__MODULE__{command: cmd, perf_limit: p_limit}
  end

  def new(cmd, t_out) when is_integer(t_out) do
    %__MODULE__{command: cmd, timeout: t_out}
  end

  def new(cmd, s_args) when is_list(s_args) do
    %__MODULE__{command: cmd, spawn_args: s_args}
  end

  @spec new(String.t(), spawn_args_type, Rwife.Settings.PerfLimit.t() | integer()) :: Rwife.Settings.PortSettings.t()
  def new(cmd, s_args, %Rwife.Settings.PerfLimit{} = p_limit) do
    %__MODULE__{command: cmd, spawn_args: s_args, perf_limit: p_limit}
  end

  def new(cmd, s_args, t_out) when is_integer(t_out) do
    %__MODULE__{command: cmd, spawn_args: s_args, timeout: t_out}
  end

  @spec new(String.t(), spawn_args_type, integer(), Rwife.Settings.PerfLimit.t) :: Rwife.Settings.PortSettings.t()
  def new(cmd, s_args, t_out, p_limit) do
    %__MODULE__{command: cmd, spawn_args: s_args, timeout: t_out, perf_limit: p_limit}
  end
end
