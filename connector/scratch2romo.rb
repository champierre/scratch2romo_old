#!/usr/bin/env ruby
# encoding: utf-8

require_relative "scratchrsc"
require "rubygems"
require "httpclient"

class PrintRSC < RSCWatcher

  def initialize
    super

    @client = HTTPClient.new
    broadcast "forward"
    broadcast "right"
    broadcast "left"
    broadcast "backward"
    broadcast "up"
    broadcast "down"
    broadcast "takePhoto"
    broadcast "turnLightOn"
    broadcast "turnLightOff"

    @angle = 30
  end

  def host=(value)
    @root_url = "http://#{value}"
  end
  
  def on_sensor_update(name, value) # when a variable or sensor is updated
    if name == "angle"
      @angle = value.to_i
    end
  end

  def broadcast_right
    puts "right"
    @client.get "#{@root_url}/right/#{@angle}"
  end
  
  def broadcast_left
    puts "left"
    @client.get "#{@root_url}/left/#{@angle}"
  end

  def broadcast_forward
    puts "forward"
    @client.get "#{@root_url}/forward"
  end

  def broadcast_backward
    puts "backward"
    @client.get "#{@root_url}/backward"
  end

  def broadcast_up
    puts "up"
    @client.get "#{@root_url}/up"
  end

  def broadcast_down
    puts "down"
    @client.get "#{@root_url}/down"
  end

  def broadcast_takePhoto
    puts "takePhoto"
    @client.get "#{@root_url}/takePhoto"
  end

  def broadcast_turnLightOn
    puts "turnLightOn"
    @client.get "#{@root_url}/turnLightOn"
  end

  def broadcast_turnLightOff
    puts "turnLightOff"
    @client.get "#{@root_url}/turnLightOff"
  end

  def on_broadcast(name)
  end
end

host = ARGV[0]
if host.nil?
  puts "please input host address like 'ruby scratch2romo.rb 10.0.1.5'"
  exit
end

watcher = PrintRSC.new # you can provide the host as an argument
watcher.host = host
watcher.sensor_update "connected", "1"
loop { watcher.handle_command }
