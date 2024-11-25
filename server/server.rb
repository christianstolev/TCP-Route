require 'socket'
require_relative '../lib/request'
require_relative '../lib/router'
require_relative '../lib/response'
class HTTPServer

    def initialize(port)
        @port = port
    end

    def start
        server = TCPServer.new(@port)
        puts "Listening on #{@port}"
        router = Router.new

        router.add_route('/add/:id/:id2', :GET) do | num1, num2 |
            "Sum: #{num1.to_i + num2.to_i}" 
        end
        router.add_route('/sub/:id/:id2', :GET) do | num1, num2 |
            "Sum: #{num1.to_i - num2.to_i}" 
        end
        router.add_route('/div/:id/:id2', :GET) do | num1, num2 |
            "Sum: #{num1.to_i / num2.to_i}" 
        end
        router.add_route('/mul/:id/:id2', :GET) do | num1, num2 |
            "Sum: #{num1.to_i * num2.to_i}" 
        end

        while session = server.accept
            data = ""
            while line = session.gets and line !~ /^\s*$/
                data += line
            end

            request = Request.new(data)
            
            data = router.match_route(request)
            
            res = Response.new(session)
            res.set_version(1.1)
            res.set_code(200)
            res.set_content_type("text/html")
            res.set_response(data)

            res.done()
        end
    end
end

server = HTTPServer.new(4567)
server.start