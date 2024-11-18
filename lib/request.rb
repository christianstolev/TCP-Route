# frozen_string_literal: true

# Class used for requests
class Request
  attr_reader :method, :resource, :version, :headers, :params, :body

  METHOD_MAP = {
    'GET' => :GET,
    'POST' => :POST,
    'DELETE' => :DELETE,
    'PUTS' => :PUTS
  }.freeze

  def initialize(request_string)
    lines = request_string.split("\r\n")
    parse_request_line(lines[0])
    @headers = parse_headers(lines)
    @body = parse_body(lines)
  end

  private

  def parse_request_line(request_line)
    parts = request_line.split(' ')
    @method = METHOD_MAP[parts[0]]
    @resource = parts[1]
    @version = parts[2]
    @params = parse_params(parts[1].split('?')[1])
  end

  def parse_params(params_string)
    return {} unless params_string

    Hash[params_string.split('&').map { |pair| pair.split('=') }]
  end

  def parse_headers(lines)
    headers = {}
    lines.each do |line|
      break if line.strip.empty?

      key, value = line.split(': ')
      headers[key] = value
    end
    headers
  end

  def parse_body(lines)
    empty_line_index = lines.index { |line| line.strip.empty? }
    lines[empty_line_index + 1] if empty_line_index
  end
end
