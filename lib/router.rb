require 'erb'

def string_is_file?(string)
    !File.extname("dir" + string).empty?
end

def is_erb_file?(string)
    File.extname(string) == ".erb"
end

def ERB_FILE(file_name)
    if is_erb_file?(file_name) then
        erb_template = ERB.new(File.read("dir/" + file_name))
        output = erb_template.result(binding)
        return output
    end
end
class RouterResponse
    def initialize
        @status_code = nil
        @mime_type = nil
        @response = nil
    end

    def status_code
        @status_code
    end

    def response
        @response
    end

    def mime_type
        @mime_type
    end
    
    def content_length
        @response.length
    end

    # Setter for status_code
    def status_code=(status_code)
        @status_code = status_code
    end

    def content_length=(content_length)
        @content_length = content_length
    end

    # Setter for mime_type
    def mime_type=(mime_type)
        @mime_type = mime_type
    end

    # Setter for response
    def response=(response)
        if @mime_type.nil? && response.length < 100 && string_is_file?(response) && File.exist?("dir/" + response) then
            @mime_type = MIME::Types.type_for(response).first
            p "is erb file?"
            if is_erb_file?(response) then
                erb_template = ERB.new(File.read("dir/" + response))
                output = erb_template.result(binding)
                @response = output
                p output
                @mime_type = 'text/html'
            else
                @response = File.read("dir/" + response)
            end
        else
            @response = response
        end
    end

end

class Router
    ROUTE_MAP = {}

    def initialize()
    end

    def add_route(route, method, &block)
        return "No block given" unless block_given?
        print("Adding route: #{route}\n")

        r_path = ""
        r_split = route.split("/")[1..]
        r_split.each_with_index do | k, v |
            print("\t#{k} => #{v}\n")
            if k.start_with?(":") then
                r_path += "/"
                r_path += "([A-Za-z0-9]+)"
            else
                r_path += "/"
                r_path += k
            end
        end

        ROUTE_MAP[route] = {
            :METHOD => method,
            :BLOCK => block,
            :ROUTE => route,
            :REGEX => r_path
        }
        ROUTE_MAP.each do |key, value|
            print("\t#{key} => #{value}\n")
        end
    end

    def route_matches(route)

        print("----------- BEGIN MATCH -------------\n")
        org_route = route.resource 
        if org_route.include?("favicon.ico") then
            return false
        end
        ROUTE_MAP.each do |key, value| 
            print("#{key} => #{value}\n")
            if org_route.match(value[:REGEX]) then
                return value
            end
        end
        print("----------- END MATCH -------------\n")
        return nil
    end
    
    def extract_parameters(r_map, org_route)
        print("----------- BEGIN EXTRACT -------------\n")
        
        p org_route
        p r_map[:REGEX]
        regex = Regexp.new(r_map[:REGEX])
        matches = org_route.match(regex)

        
        print("----------- END EXTRACT -------------\n")
        return r_map[:BLOCK], matches.captures
    end

    def match_route(route)
        r_map = route_matches(route)
        if r_map then
            bl, args = extract_parameters(r_map, route.resource)
            rs = RouterResponse.new()
            bl.call(rs, *args)
            return rs
        else
            if string_is_file?("dir" + route.resource) && File.exist?("dir" + route.resource) then
                rs = RouterResponse.new()
                rs.status_code = 200
                rs.response = File.binread("dir" + route.resource)
                rs.mime_type = MIME::Types.type_for(route.resource).first
                p rs.mime_type
                return rs
            else
                rs = RouterResponse.new()
                rs.status_code = 404
                rs.response = "<h1>404 Not Found</h1>"
                rs.mime_type = "text/html"
                return rs
            end
        end
        
    end
end
