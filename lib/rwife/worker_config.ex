defmodule Rwife.WorkerConfig do
  @type t :: %__MODULE__{}

  defstruct [port_settings: nil, kill_method: nil, limits: []]
  def new(port_settings) do
    %Rwife.WorkerConfig{
      port_settings: port_settings
    }
  end

  def new(p_settings, k_method, limits) do
    %Rwife.WorkerConfig{
      port_settings: p_settings,
      kill_method: k_method,
      limits: limits
    }
  end

  def port_settings(cmd) do
    Rwife.Settings.PortSettings.new(cmd)
  end

  def port_settings(cmd, s_args) do
    Rwife.Settings.PortSettings.new(cmd, s_args)
  end

  def port_settings(cmd, s_args, t_out) do
    Rwife.Settings.PortSettings.new(cmd, s_args, t_out)
  end
end
