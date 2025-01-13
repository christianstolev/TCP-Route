require 'socket'
require_relative '../lib/request'
require_relative '../lib/router'
require_relative '../lib/response'

require 'mime/types'

class HTTPServer
  # Initializes the HTTPServer with the specified port.
  # @param port [Integer] The port to listen on.
  def initialize(port)
    @port = port
  end

  # Starts the HTTP server, sets up routes, and listens for incoming requests.
  def start
    server = TCPServer.new(@port)
    puts "Listening on #{@port}"
    router = Router.new

    # Define routes here
    router.add_route('/main', :GET) do |r|
      r.status_code = 200
      r.response = 'page.html'
    end

    router.add_route('/add/:id1/:id2', :GET) do |r, id1, id2|
      r.status_code = 200
      calc = id1.to_f + id2.to_f
      r.response = calc.to_s
    end

    router.add_route('/data', :POST) do |req, res|
      print('From /data ', req.body, "\n")
      res.response = 'Hello to you too!'
    end

    router.add_route('/zesty', :GET) do |r|
      r.status_code = 200
      r.response = 'Sweden_Passport_2022-EXAMPLE.jpg'
    end

    router.add_route('/sinatra', :GET) do |r|
      r.status_code = 200
      @message = 'Hello, thideqds is a dynamic message!'
      r.response = ERB_FILE('ruby.erb')
      r.mime_type = 'text/html'
    end

    while session = server.accept
      data = ''
      while line = session.gets and line !~ /^\s*$/
        data += line
      end

      # Parse headers to extract Content-Length
      headers = data.split("\r\n")
      content_length = headers.find { |h| h =~ /Content-Length/ }
      content_length = if content_length
                         content_length.split(': ')[1].to_i
                       else
                         0
                       end

      body = session.read(content_length) if content_length > 0

      p data
      request = Request.new(data, body)

      rs = router.match_route(request)

      print("Rs: #{rs}\n")
      res = Response.new(rs, session)

      res.done
    end
  end
end

server = HTTPServer.new(4567)
server.start
