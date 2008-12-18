#!/usr/bin/env ruby -w
require 'expect'
require 'socket'
require 'logger'

include Process

$log            = Logger.new($stdout)
$log.progname   = "player1"
$expect_verbose = true

cmd = (ARGV + ["-p", "4321", "mazesofmayhem.dat"]).join(" ")
$log.info "Starting server: #{cmd}"
IO.popen(cmd, 'r+') do |server|
  $log.info "Waiting for game server to start..."
  server.expect(/ready\n/i)
  $log.info "Game server started!"
end
server_status = $?
server_pid = server_status.pid
$log.info "Server PID is #{server_pid}"

host = "localhost"
port = 4321
$log.info "Opening connection to server #{host}:#{port}"
server = TCPSocket.new(host, port)
$log.info "Sending newline to server"
server.puts

$log.info "Killing server"
kill("TERM", server_pid)
$log.info "Waiting for server process to end"
wait(server_pid)
$log.info "Server process finished"
