# frozen_string_literal: true

# Class used to parse and represent HTTP requests
class Request
  attr_reader :method, :resource, :version, :headers, :params, :body

  METHOD_MAP = {
    'GET' => :GET,
    'POST' => :POST,
    'DELETE' => :DELETE,
    'PUTS' => :PUTS
  }.freeze

  # Initializes the Request object by parsing the given request string.
  # @param request_string [String] The raw HTTP request string.
  def initialize(request_string)
    lines = request_string.split("\r\n")
    parse_request_line(lines[0])
    @headers = parse_headers(lines)
    @body = parse_body(lines)
  end

  private

  # Parses the request line to extract method, resource, HTTP version, and query parameters.
  # @param request_line [String] The first line of the HTTP request.
  def parse_request_line(request_line)
    parts = request_line.split(' ')
    @method = METHOD_MAP[parts[0]]
    @resource = parts[1]
    @version = parts[2]
    @params = parse_params(parts[1].split('?')[1])
  end

  # Parses the query parameters from the request URI.
  # @param params_string [String] The query string.
  # @return [Hash] Parsed query parameters.
  def parse_params(params_string)
    return {} unless params_string

    Hash[params_string.split('&').map { |pair| pair.split('=') }]
  end

  # Parses the headers from the HTTP request.
  # @param lines [Array<String>] All lines from the HTTP request.
  # @return [Hash] Parsed headers.
  def parse_headers(lines)
    headers = {}
    lines.each do |line|
      break if line.strip.empty?

      key, value = line.split(': ')
      headers[key] = value
    end
    headers
  end

  # Extracts the body from the HTTP request.
  # @param lines [Array<String>] All lines from the HTTP request.
  # @return [String, nil] The body content or nil if not present.
  def parse_body(lines)
    empty_line_index = lines.index { |line| line.strip.empty? }
    lines[empty_line_index + 1] if empty_line_index
  end
end
