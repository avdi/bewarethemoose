#!/usr/bin/env ruby -w
require 'expect'
require 'socket'

include Process

$expect_verbose = true

cmd = (ARGV + ["-p", "4321", "mazesofmayhem.dat"]).join(" ")
IO.popen(cmd) do |server|
  server.expect(/ready/i)
end
server_status = $?
server_pid = server_status.pid

kill("TERM", server_pid)
wait(server_pid)
