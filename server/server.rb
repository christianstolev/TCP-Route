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
        router.add_route('/test', :GET) do |r|
            r.status_code = 200
            r.response = "Hello World"
            r.mime_type = 'text/plain'
        end

        router.add_route('/hello', :GET) do |r|
            r.status_code = 200
            r.response = "page.html"
        end

        router.add_route('/zesty', :GET) do |r|
            r.status_code = 200
            r.response = "Sweden_Passport_2022-EXAMPLE.jpg"
        end

        router.add_route('/sinatra', :GET) do |r|
            r.status_code = 200
            @message = "Hello, thideqds is a dynamic message!"
            r.response = ERB_FILE("ruby.erb")
            r.mime_type = 'text/html'
        end

        while session = server.accept
            data = ""
            while line = session.gets and line !~ /^\s*$/
                data += line
            end

            request = Request.new(data)
            
            rs = router.match_route(request)
            print("Rs: #{rs}\n")
            res = Response.new(session)
            res.set_version(1.1)
            res.set_code(rs.status_code)
            res.set_content_type(rs.mime_type)
            res.set_response(rs.response)

            res.done()
        end
    end
end

server = HTTPServer.new(4567)
server.start
