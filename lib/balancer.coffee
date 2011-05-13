http = require('http');

class Balancer extends http.Server
  constructor: (servers) ->
    @servers = (http.createClient(server.port, server.url) for server in servers)
    @counter = 0
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
    server = @servers[@counter]
    @counter = (@counter+1)%2
    server

module.exports = Balancer