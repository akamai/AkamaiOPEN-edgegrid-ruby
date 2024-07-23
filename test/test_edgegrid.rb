#!/usr/bin/env ruby
#
# Original author: Jonathan Landis <jlandis@akamai.com>
#
# For more information visit https://developer.akamai.com
#
#   Copyright 2024 Akamai Technologies, Inc.  All rights reserved.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter 'test'
    command_name 'Mintest'
  end
end

require 'minitest'
require 'minitest/autorun'
require 'json'
require 'uri'
require_relative '../lib/akamai/edgegrid'

class EdgegridTest < Minitest::Test
  @@testdata = JSON.parse(File.read("#{File.dirname(__FILE__)}/testdata.json"))

  @@testdata['tests'].each do |testcase|
    define_method("test_#{testcase['testName'].downcase.tr(" ", "_")}") do
      baseuri = URI(@@testdata['base_url'])
      http = Akamai::Edgegrid::HTTP.new(
        address=baseuri.host,
        port=baseuri.port
      )

      http.setup_edgegrid(
        :client_token => @@testdata['client_token'],
        :client_secret => @@testdata['client_secret'],
        :access_token => @@testdata['access_token'],
        :max_body => @@testdata['max_body'],
        :headers_to_sign => @@testdata['headers_to_sign']
      )

      request_class = Net::HTTP.const_get(testcase['request']['method'].capitalize)
      request = request_class.new URI.join(baseuri.to_s, testcase['request']['path']).to_s

      if testcase['request']['headers']
        testcase['request']['headers'].each do |header|
          header.each do |k,v|
            request.add_field(k,v)
          end
        end
      end

      if testcase['request']['data']
        request.body = testcase['request']['data']
      end

      begin
        auth_header = http.make_auth_header(
          request,
          @@testdata['timestamp'],
          @@testdata['nonce']
        )
        assert_equal(testcase['expectedAuthorization'], auth_header)

      rescue RuntimeError => err
        assert_equal(testcase['failsWithMessage'], err.message)
      end
    end
  end

  def test_nonce
    count = 100
    nonces = {}
    while count > 0 do
      n = Akamai::Edgegrid::HTTP.new_nonce()
      refute_includes(nonces, n)
      nonces[n] = 1
      count -= 1
    end
  end

  def test_timestamp
    assert_match(/^
        \d{4}       # year
        [0-1][0-9]  # month
        [0-3][0-9]  # day
        T
        [0-2][0-9]  # hour
        :
        [0-5][0-9]  # minute
        :
        [0-5][0-9]  # second
        [+]0000     # timezone
    $/x, Akamai::Edgegrid::HTTP.eg_timestamp())
  end
end
