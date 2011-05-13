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
    console.log(req.params)
    unless serverStatus[req.body.server]
      this.serverStatus[req.body.server](new ServerStatus(req.body.status))
    res.writeHead(200)
    res.end()


module.exports = MonitorFoo