require 'erb'

# Utility method to check if a string represents a file.
# @param string [String] The string to check.
# @return [Boolean] True if the string is a file, false otherwise.
def string_is_file?(string)
  !File.extname("dir" + string).empty?
end

# Utility method to check if a file is an ERB template.
# @param string [String] The file name to check.
# @return [Boolean] True if the file is an ERB template, false otherwise.
def is_erb_file?(string)
  File.extname(string) == ".erb"
end

# Utility method to check if a file is an image.
# @param filename [String] The file name to check.
# @return [Boolean] True if the file is an image, false otherwise.
def is_image?(filename)
  mime_type = MIME::Types.type_for(filename).first
  mime_type&.media_type == 'image'
end

# Processes an ERB template file and returns the rendered content.
# @param file_name [String] The name of the ERB template file.
# @return [String] The rendered content of the ERB template.
def ERB_FILE(file_name)
  if is_erb_file?(file_name)
    erb_template = ERB.new(File.read("dir/" + file_name))
    output = erb_template.result(binding)
    return output
  end
end

# Represents the response from a route in the router.
class RouterResponse
  attr_accessor :status_code, :mime_type, :response

  # Initializes the RouterResponse object with default values.
  def initialize
    @status_code = nil
    @mime_type = nil
    @response = nil
  end
  
  # Calculates the content length of the response.
  # @return [Integer] The length of the response content.
  def content_length
    @response.length
  end

  # Sets the response content and determines MIME type if necessary.
  # @param response [String] The response content OR file name.
  def response=(response)
    if @mime_type.nil? && response.length < 100 && string_is_file?(response) && File.exist?("dir/" + response) then
      @mime_type = MIME::Types.type_for(response).first
      print("Detected mime type: #{@mime_type} for file #{response}\n")
      if is_erb_file?(response)
        print("File is ERB!\n")
        erb_template = ERB.new(File.read("dir/" + response))
        output = erb_template.result(binding)
        @response = output
        @mime_type = 'text/html'
      elsif is_image?(response)
        print("File is IMG!\n")
        @response = File.binread("dir/" + response)
      else
        @response = File.read("dir/" + response)
        print("Response is #{@response}\n")
      end
    else
      @response = response
    end
  end
end

# Router class for managing HTTP routes and processing requests.
class Router
  ROUTE_MAP = {}

  # Initializes the Router.
  def initialize
  end

  # Adds a route to the router with a specific HTTP method and block to execute.
  # @param route [String] The route path.
  # @param method [Symbol] The HTTP method (e.g., :GET, :POST).
  # @param block [Proc] The block to execute when the route matches.
  def add_route(route, method, &block)
    return "No block given" unless block_given?

    print("Adding route: #{route}\n")
    r_path = route.split("/")[1..].map do |k|
      k.start_with?(":") ? "([A-Za-z0-9]+)" : k
    end.join("/")
    r_path = "/#{r_path}"
    print("Route regex: #{r_path}\n")

    ROUTE_MAP[route] = {
      METHOD: method,
      BLOCK: block,
      ROUTE: route,
      REGEX: r_path
    }
  end

  # Finds a matching route for the given request.
  # @param route [Request] The incoming request object.
  # @return [Hash, nil] The matching route map or nil if not found.
  def route_matches(route)
    print("----------- BEGIN MATCH -------------\n")
    org_route = route.resource
    return false if org_route.include?("favicon.ico")
    ROUTE_MAP.find { |key, value| org_route.match(value[:REGEX]) }&.last
  end

  # Extracts parameters from the matched route.
  # @param r_map [Hash] The route map.
  # @param org_route [String] The original route string.
  # @return [Array] The block and extracted parameters.
  def extract_parameters(r_map, org_route)
    regex = Regexp.new(r_map[:REGEX])
    matches = org_route.match(regex)
    [r_map[:BLOCK], matches.captures]
  end

  # Matches a route and processes the response.
  # @param route [Request] The incoming request object.
  # @return [RouterResponse] The processed response object.
  def match_route(route)
    r_map = route_matches(route)
    if r_map
      bl, args = extract_parameters(r_map, route.resource)
      rs = RouterResponse.new
      bl.call(rs, *args)
      return rs
    elsif string_is_file?("dir" + route.resource) && File.exist?("dir" + route.resource)
      rs = RouterResponse.new
      rs.status_code = 200
      rs.response = File.binread("dir" + route.resource)
      rs.mime_type = MIME::Types.type_for(route.resource).first
      return rs
    else
      rs = RouterResponse.new
      rs.status_code = 404
      rs.response = "<h1>404 Not Found</h1>"
      rs.mime_type = "text/html"
      return rs
    end
  end
end
