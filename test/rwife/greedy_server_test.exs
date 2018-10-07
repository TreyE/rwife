defmodule Rwife.GreedyServerTest do
  use ExUnit.Case

  test "is killed for using too much ram" do
    me_pid = self()
    {:ok, pm_pid} = Rwife.Workers.PerfMonitor.start_link()
    spawn(fn  ->
      Process.flag(:trap_exit, true)
      perf_limit = Rwife.Settings.PerfLimit.new(:SIGINT, [Rwife.Settings.PerfLimit.max_memory_limit(100)])
      settings = Rwife.Settings.PortSettings.new("ruby test/rwife/packet_port.rb", perf_limit)
      {:ok, spid} = Rwife.PacketServer.start_link(settings)
      send(me_pid, spid)
      receive do
        a ->
          send(me_pid, a)
      end
    end)
    ps_pid = receive do
      a -> a
    after
      30000 -> assert(false, "did not get server pid")
    end
    receive do
      {:EXIT, ^ps_pid, {:port_exit, _, reason}} -> assert(^reason = 130)
      _ ->  assert(false, "did not get exit signal in time")
    end
    GenServer.stop(pm_pid)
  end
end
