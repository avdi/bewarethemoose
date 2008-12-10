#!/usr/bin/env ruby
require 'rubygems'
require 'main'
require 'socket'
require 'gserver'

class AdventureServer < GServer
  def initialize(port, *args)
    super(port, *args)
  end
  def serve(io)
    io.puts("ready")
    io.gets
  end
end

Main do
  argument 'file' do
    required
  end
  option('port', 'p') do
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
    server.join
  end
end
