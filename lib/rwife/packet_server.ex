defmodule Rwife.PacketServer do
  use GenServer

  def start_link(settings) do
    :gen_server.start_link(__MODULE__, settings, [])
  end

  def init(settings) do
    {spawned_port, os_pid} = start_port(settings)
    {:ok, {settings.port_settings, spawned_port, os_pid}}
  end

  def handle_call(:server_info, _from, {settings, port, os_pid}) do
    {:reply, Rwife.Workers.WorkerInfo.new(settings, port, self(), os_pid), {settings, port, os_pid}}
  end

  def handle_call({:sync_call, data}, _from, {settings, port, os_pid}) do
    case call_port(port, data, settings) do
      {:ok, reply} ->
        {:reply, reply, {settings, port, os_pid}}
      {:error, :timeout} ->
        {:reply, {:timeout, data}, {settings, port, os_pid}}
      {:error, {:port_exit, err_port, e_status}} ->
        {:stop, {:port_exit, err_port, e_status}}
      {:error, err_data} ->
        {:stop, {:port_error, data, err_data}, {settings, port, os_pid}}
    end
  end

  def request(pid, data) do
    GenServer.call(pid, {:sync_call, data})
  end

  def server_info(pid) do
    GenServer.call(pid, :server_info)
  end

  def handle_info(info, state) do
    case info do
      {:EXIT, err_port, reason} ->
        {:stop, {:port_exit, err_port, reason}, state}
      {err_port, {:exit_status, e_status}} ->
        {:stop, {:port_exit, err_port, e_status}, state}
      _ -> {:stop, {:message_not_understood, info}, state}
    end
  end

  def terminate(_reason, {_settings, port, _os_pid}) do
    stop_port(port)
  end

  defp call_port(port, cmd, settings) do
    :erlang.port_command(port, cmd)
    receive do
      {:EXIT, err_port, reason} -> {:error, {:port_exit, err_port, reason}}
      {_r_port, {:data, data}} -> {:ok, data}
      {err_port, {:exit_status, e_status}} -> {:error, {:port_exit, err_port, e_status}}
      other_message -> {:error, {:unknown_port_message, other_message}}
    after
      settings.timeout -> {:error, :timeout}
    end
  end

  defp start_port(settings) do
    Process.flag(:trap_exit, true)
    port =
      :erlang.open_port(
        {:spawn, settings.port_settings.command},
        [{:packet, 4}, :binary, :use_stdio, :exit_status] ++ settings.port_settings.spawn_args
      )

    :erlang.port_connect(port, self())
    p_info = :erlang.port_info(port)
    {port, p_info[:os_pid]}
  end

  defp stop_port(port) do
    case :erlang.port_info(port) do
      :undefined -> :ok
      _ ->
        :erlang.port_close(port)
        receive do
          {:EXIT, ^port, :normal} -> :ok
          {^port, {:exit_status, _}} -> :ok
          a ->
            {:shutdown_error, a}
        end
    end
  end
end
