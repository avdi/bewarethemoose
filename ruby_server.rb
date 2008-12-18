#!/usr/bin/env ruby
require 'rubygems'
require 'main'
require 'socket'
require 'gserver'

$stdout.sync = true

class AdventureServer < GServer
  def initialize(port, *args)
    super(port, *args)
  end
  def serve(io)
    io.sync = true
    io.puts("Hello!")
    io.gets
  end
end

Main do
  argument 'file' do
    required
  end
  option('port=port', 'p') do
    cast    :int
    default 4321
  end
  option('debug', 'd') do
    cast    :bool
    default false
  end

  def run
    data = File.open(params['file'].value).read
    port = params['port'].value
    server = AdventureServer.new(port, data)
    server.audit = params['debug'].value
    trap("INT") do
      puts "Shutting down..."
      server.stop
      puts "Finished."
    end
    server.start
    puts "ready"
    server.join
  end
end
