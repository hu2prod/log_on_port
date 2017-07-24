#!/usr/bin/iced
### !pragma coverage-skip-block ###
require 'fy'
WebSocket = require 'ws'
argv = require('minimist')(process.argv.slice(2))
# ###################################################################################################
#    config
# ###################################################################################################
argv.port ?= 3334
argv.size ?= 1024*1024 # 1 Mb
argv.line_limit ?= 1000

# ###################################################################################################
wss = new WebSocket.Server { port: argv.port }

line_list = []
data_chunk = ""
msg = JSON.stringify {line_list}

process.stdin.on 'readable', ()->
  chunk = process.stdin.read()
  return if !chunk?
  process.stdout.write chunk
  data_chunk += chunk
  
  if data_chunk.length > argv.size
    data_chunk = data_chunk.substr(data_chunk.length-argv.size, argv.size)
  line_list = data_chunk.split /\n/g
  if line_list.length > argv.line_limit
    p line_list.length-argv.line_limit
    line_list = line_list.slice(line_list.length-argv.line_limit)
  
  msg = JSON.stringify {line_list}
  
  wss.clients.forEach (client)->
    return if client.readyState != WebSocket.OPEN
    client.send msg
    return
  return

wss.on 'connection', (client)->
  client.send msg
  return
