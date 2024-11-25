class Router
    ROUTE_MAP = {}

    def initialize()
    end

    def add_route(route, method, &block)
        return "No block given" unless block_given?
        ROUTE_MAP[route] = {
            :METHOD => method,
            :BLOCK => block,
            :ROUTE => route
        }
    end

    def route_matches(route)

        org_route = route.resource 
        route_s = org_route.split('/')[1..]
        ret_val = false
        ROUTE_MAP.each do |r| 
            mapped_route = r[1][:ROUTE].split('/')[1..]
            if mapped_route == nil || route_s == nil then
                return false
            end
            if mapped_route.length == route_s.length && route.method == r[1][:METHOD] then
                print("match ", mapped_route, "\n")
                anomaly_found = false
                mapped_route.map.with_index do | x, i |
                    if x.start_with?(':') then
                        print(x, " should be ", route_s[i], "\n")
                        mapped_route[i] = route_s[i]
                    else
                        if x != route_s[i] then
                            print("ANOMALY FOUND!\n")
                            return false
                        end
                    end
                end
                return true
            end
        end
        return false 
    end
    
    def extract_parameters(org_route)
        route_s = org_route.split('/')[1..]
        ret_val = false
        ROUTE_MAP.each do |r| 
            mapped_route = r[1][:ROUTE].split('/')[1..]
            if mapped_route.length == route_s.length then
                anomaly_found = false
                out = []
                r_block = r[1][:BLOCK]
                mapped_route.map.with_index do | x, i |
                    if x.start_with?(':') then
                        out[i] = route_s[i]
                    else
                        if x != route_s[i] then
                            return false
                        end
                    end
                end
                return r_block, out.compact!
            end
        end
        return false 
    end

    def match_route(route)
        
        if route_matches(route) then
            bl, args = extract_parameters(route.resource)
            bl.call(*args)
        end
        
    end
end
