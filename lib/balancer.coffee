http = require('http');

class Balancer extends http.Server
  constructor: (monitor) ->
    #@servers = (http.createClient(server.port, server.url) for server in servers)
    @monitor = monitor
    super(this.requestHandler)

  requestHandler: (req, res) ->
    proxy_request = this.nextServer().request(req.method, req.url, req.headers)
    proxy_request.addListener 'response', (proxy_res) ->
      proxy_res.addListener 'data', (chunk) -> res.write chunk, 'binary'

      proxy_res.addListener 'end', -> res.end()

      res.writeHead proxy_res.statusCode

    req.addListener 'data', (chunk) -> proxy_request.write(chunk)

    req.addListener 'end', -> proxy_request.end()

  nextServer: ->
    console.log(@monitor)
    console.log(@monitor.serverStatus())
    servers = @monitor.serverStatus()
    server = null
    for s of servers
      if(server == null)
        server = servers[s]
      else if(servers[s].loadavg[0] < server.loadavg[0])
        server = servers[s]
    console.log("choose: " + server.host)
    http.createClient(server.port, server.host)

module.exports = Balancer
