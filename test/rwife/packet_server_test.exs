defmodule Rwife.PacketServerTest do
  use ExUnit.Case

  test "a simple echo server" do
    settings = %Rwife.PortSettings{command: "ruby test/rwife/packet_port.rb"}
    {:ok, pid} = Rwife.PacketServer.start_link(settings)
    result = GenServer.call(pid, "HI!")
    assert result == "HI!"
    GenServer.stop(pid)
  end
end
