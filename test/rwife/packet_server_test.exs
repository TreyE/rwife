defmodule Rwife.PacketServerTest do
  use ExUnit.Case

  test "a simple echo server" do
    settings = %Rwife.PortSettings{command: "ruby test/rwife/packet_port.rb"}
    {:ok, pid} = Rwife.PacketServer.start_link(settings)
    result = Rwife.PacketServer.request(pid, "HI!")
    assert result == "HI!"
    GenServer.stop(pid)
  end

  test "a killed server" do
    settings = %Rwife.PortSettings{command: "ruby test/rwife/packet_port.rb"}
    {:ok, pid} = Rwife.PacketServer.start_link(settings)
    p_info = Rwife.PacketServer.server_info(pid)
    Process.flag(:trap_exit, true)
    System.cmd("kill", ["-9", "#{p_info.os_pid}"])
    receive do
      {:EXIT, ^pid, {:port_exit, _, status}} -> assert(137 = status)
    end
    Process.flag(:trap_exit, false)
  end
end
