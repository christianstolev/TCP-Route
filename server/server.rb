require 'socket'
require_relative '../lib/request'
require_relative '../lib/router'
require_relative '../lib/response'

require 'mime/types'

class HTTPServer

    def initialize(port)
        @port = port
    end

    def start
        server = TCPServer.new(@port)
        puts "Listening on #{@port}"
        router = Router.new

        #router.add_route('/add/:id/:id2', :GET) do | num1, num2 |
        #    "Sum: #{num1.to_i + num2.to_i}" 
        #end
        #router.add_route('/sub/:id/:id2', :GET) do | num1, num2 |
        #    "#{num1} - #{num2} = #{num1.to_i - num2.to_i}" 
        #end
        #router.add_route('/div/:id/:id2', :GET) do | num1, num2 |
        #    "Sum: #{num1.to_i / num2.to_i}" 
        #end
        #router.add_route('/mul/:id/:id2', :GET) do | num1, num2 |
        #    "Sum: #{num1.to_i * num2.to_i}" 
        #end

        router.add_route('/test', :GET) do | r |
            r.status_code = 200
            r.response = "Hello World"
            r.mime_type = 'text/plain'
        end

        router.add_route('/hello', :GET) do | r |
            r.status_code = 200
            r.response = "test.html"
        end
        router.add_route('/doge', :GET) do | r |
            r.status_code = 200
            r.response = "image.png"
        end

        router.add_route('/sinatra', :GET) do | r |
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
            #print("Code: #{code} Data: #{data}\n")
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