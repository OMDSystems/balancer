express = require('express')

serverStatus = {}

MonitorFoo =
  createMonitor: () ->
    monitor = express.createServer()
    monitor.post '/report', this.handleStatusReport
    monitor.get '/', this.handleStatusRequest
    monitor

  serverStatus: () -> serverStatus

  handleStatusRequest: (req, res) ->
    res.render('index', {
      title: 'foo',
      status: serverStatus
    })

  handleStatusReport: (req, res) ->
    data = ''
    req.on 'data', (chunk) ->
      data += chunk
    req.on 'end', () ->
      console.log("got status")
      status = JSON.parse(data)
      status.lastseen = Date.now()
      serverStatus[status.host] = status
      res.writeHead(200)
      res.end()

module.exports = MonitorFoo
