defmodule Rwife.PacketServerTest do
  use ExUnit.Case

  test "a simple echo server" do
    ps = Rwife.WorkerConfig.port_settings("ruby test/rwife/packet_port.rb")
    settings = Rwife.WorkerConfig.new(ps)
    {:ok, pid} = Rwife.PacketServer.start_link(settings)
    result = Rwife.PacketServer.request(pid, "HI!")
    assert result == "HI!"
    :ok = GenServer.stop(pid)
  end

  test "a killed server" do
    me_pid = self()
    spawn(fn  ->
      Process.flag(:trap_exit, true)
      ps = Rwife.WorkerConfig.port_settings("ruby test/rwife/packet_port.rb")
      settings = Rwife.WorkerConfig.new(ps)
      {:ok, spid} = Rwife.PacketServer.start_link(settings)
      send(me_pid, {:rwife_server_pid, spid})
      p_info = Rwife.PacketServer.server_info(spid)
      :os.cmd(to_charlist("kill -9 #{p_info.os_pid}"))
      receive do
        a ->
          send(me_pid, a)
      end
    end)
    pid = receive do
      {:rwife_server_pid, rs_pid} -> rs_pid
      _ -> assert(false, "did not get server pid message")
    end
    receive do
      {:EXIT, ^pid, {:port_exit, _, status}} -> assert(137 = status)
    end
  end
end
