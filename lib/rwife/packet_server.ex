defmodule Rwife.PacketServer do

  use GenServer

  def start_link(port_settings) do
    :gen_server.start_link(__MODULE__, port_settings, [])
  end

  def init(port_settings) do
    spawned_port = start_port(port_settings)
    {:ok, {port_settings, spawned_port}}
  end

  def handle_call(data, _from, {settings, port}) do
    case call_port(port, data, settings) do
      {:ok, reply} -> {:reply, reply, {settings, port}}
      {:error, :timeout} -> {:reply, {:timeout, data}, {settings, port}}
    end
  end

  def handle_info(info, state) do
    case info do
      {port,{:exit_status,e_status}} -> {:stop, {:port_exit, port, e_status}, state}
      _ -> {:stop, {:message_not_understood, info}, state}
    end
  end

  def terminate(_reason, {_settings, port}) do
    stop_port(port)
  end

  defp call_port(port, cmd, settings) do
    :erlang.port_command(port, cmd)
    receive do
      {_r_port, {:data, data}} -> {:ok, data}
    after
      settings.timeout -> {:error, :timeout}
    end
  end

  defp start_port(settings) do
    port = :erlang.open_port({:spawn, settings.command}, [{:packet, 4}, :binary, :nouse_stdio, :exit_status] ++ settings.spawn_args)
    :erlang.port_connect(port, self())
    port
  end

  defp stop_port(port) do
    case :erlang.port_info(port) do
      :undefined -> :ok
      _ -> :erlang.port_close(port)
    end
  end

end
