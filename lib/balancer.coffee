http = require('http');

class Balancer extends http.Server
  constructor: (monitor) ->
    #@servers = (http.createClient(server.port, server.url) for server in servers)
    @monitor = monitor
    super(this.requestHandler)

  requestHandler: (req, res) ->
    server = this.nextServer()
    if server != null
      proxy_request = server.request(req.method, req.url, req.headers)
      proxy_request.addListener 'response', (proxy_res) ->
        proxy_res.addListener 'data', (chunk) -> res.write chunk, 'binary'

        proxy_res.addListener 'end', -> res.end()

        res.writeHead proxy_res.statusCode

      req.addListener 'data', (chunk) -> proxy_request.write(chunk)

      req.addListener 'end', -> proxy_request.end()
    else
      res.writeHead 500
      res.end()

  nextServer: ->
    servers = @monitor.serverStatus()
    server = null
    for s of servers
      if(server == null)
        server = servers[s]
      else if(servers[s].loadavg[0] < server.loadavg[0] && servers[s].lastseen < Date.now() - 4000)
        server = servers[s]
    if server != null
      console.log("choose: " + server.host)
      http.createClient(server.port, server.host)
    else
      null

module.exports = Balancer
