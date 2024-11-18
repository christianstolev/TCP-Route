# frozen_string_literal: true

require_relative 'spec_helper'
require_relative '../lib/request'

describe 'Request' do
  describe 'Simple get-request' do
    it 'parses the resource' do
      request_string = File.read('./test/example_requests/get-fruits-with-filter.request.txt')
      request = Request.new(request_string)
      p request
      _(request.resource).must_equal '/fruits?type=bananas&minrating=4'
    end
  end
end
