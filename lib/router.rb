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
            return 200, bl.call(*args)
        else
            return 404, "<h1>404 not found!</h1>"
        end
        
    end
end
