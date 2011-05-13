express = require('express')

serverStatus = {}

MonitorFoo =
  createMonitor: () ->
    monitor = express.createServer()
    monitor.post '/report', this.handleStatusReport
    monitor.get '/', this.handleStatusRequest
    monitor

  handleStatusRequest: (req, res) ->
    res.write(JSON.stringify(serverStatus))
    res.end()

  handleStatusReport: (req, res) ->
    data = ''
    req.on 'data', (chunk) ->
      data += chunk
    req.on 'end', () ->
      status = JSON.parse(data)
      serverStatus[status.host] = status.data
      res.writeHead(200)
      res.end()

module.exports = MonitorFoo