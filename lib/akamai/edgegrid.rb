#
# = akamai/edgegrid.rb
#
# Original Author: Jonathan Landis <jlandis@akamai.com>
#
# For more information visit https://developer.akamai.com
#
# == License
#
#   Copyright 2014-2015 Akamai Technologies, Inc. All rights reserved.
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

require 'openssl'
require 'base64'
require 'logger'
require 'securerandom'
require 'uri'
require 'net/http'
require 'inifile'

module Akamai #:nodoc:
  module Edgegrid #:nodoc:
    
    # == Akamai::Edgegrid::HTTP {OPEN} client
    #
    # Akamai::Edgegrid::HTTP provides a subclass of Net::HTTP that adds EdgeGrid
    # authentication support as specified at
    # https://developer.akamai.com/introduction/Client_Auth.html
    #
    # == Example:
    #   >> require 'akamai/edgegrid'
    #   >> require 'net/http'
    #   >> require 'uri'
    #   >> require 'json'
    #
    #   >> baseuri = URI('https://akaa-xxxxxxxxxxxx.luna.akamaiapis.net/')
    #   >> http = Akamai::Edgegrid::HTTP.new(address, port)
    #   >> http.setup_edgegrid(
    #         :client_token => 'ccccccccc',
    #         :client_secret => 'ssssssssssssssssss',
    #         :access_token => 'aaaaaaaaaaaaaa'
    #      )
    #   >> request = Net::HTTP::Get.new URI.join(
    #         baseuri.to_s, '/diagnostic-tools/v1/locations'
    #      ).to_s
    #   >> response = http.request(request)
    #   >> puts JSON.parse(response.body)['locations'][0]
    #   => "Hongkong, Hong Kong
    #
    class HTTP < Net::HTTP
      attr_accessor :host, :section
      private

      def self.base64_hmac_sha256(data, key)
        return Base64.encode64(
          OpenSSL::HMAC.digest(OpenSSL::Digest::SHA256.new, key, data)
        ).strip()
      end

      def self.base64_sha256(data)
        return Base64.encode64(
            OpenSSL::Digest::SHA256.new.digest(data)
        ).strip()
      end

      public

      # Creates a new Akamai::Edgegrid::HTTP object (takes same options as Net::HTTP)
      def initialize(address, port, filename='~/.edgerc', section='default')
	if filename
      		edgerc_path = File.expand_path(filename)
      	
      		if File.exist?(edgerc_path) 
            		@section = section
            		file = IniFile.load(edgerc_path)
      			data = file[address]
      			address = data["host"] || ""
            		address.gsub!('/','')
            		@host = address
      		end
      	end
		
        super(address, port)
        if port == 80
          @use_ssl = false
        else
          @use_ssl = true
          @verify_mode = OpenSSL::SSL::VERIFY_PEER
        end
      end

      # Creates a signing key based on the secret and timestamp
      def make_signing_key(timestamp)
        signing_key = self.class.base64_hmac_sha256(timestamp, @client_secret)
        @log.debug("signing key: #{signing_key}")
        return signing_key
      end

      # Returns the @headers_to_sign in normalized form
      def canonicalize_headers(request)
        return @headers_to_sign.select { |header| 
          request.key?(header) 
        }.map { |header|
          "#{header.downcase}:#{request[header].strip.gsub(%r{\s+}, ' ')}"
        }.join("\t")
      end

      # Returns a hash of the HTTP POST body
      def make_content_hash(request) 
        if request.method == 'POST' and request.body and request.body.length > 0
          body = request.body
          if body.length > @max_body
            @log.debug("data length #{body.length} is larger than maximum #{@max_body}")
            body = body[0..@max_body-1]
            @log.debug("data truncated to #{body.length} for computing the hash")
          end

          return self.class.base64_sha256(body)
        end
        return ""
      end

      # Returns a string with all data that will be signed
      def make_data_to_sign(request, auth_header)
        url = URI(request.path)
        data_to_sign = [
          request.method,
          url.scheme,
          request.key?('host') ? request['host'] : url.host,
          url.request_uri,
          canonicalize_headers(request),
          make_content_hash(request),
          auth_header
        ].join("\t")

        @log.debug("data to sign: #{data_to_sign.gsub("\t", '\\t')}")
        return data_to_sign
      end

      # Returns a signature of the given request, timestamp and auth_header
      def sign_request(request, timestamp, auth_header)
        return self.class.base64_hmac_sha256(
          make_data_to_sign(request, auth_header),
          make_signing_key(timestamp)
        )
      end

      alias_method :orig_request, :request

      # returns the current time in the format understood by Edgegrid
      def self.eg_timestamp()
        return Time.now.utc.strftime('%Y%m%dT%H:%M:%S+0000')
      end

      # returns a new nonce (unique identifier)
      def self.new_nonce()
        return SecureRandom.uuid
      end

      # Configures Akamai::Edgegrid::HTTP for use
      #
      # ==== Options
      # * +:client_token+ - Client Token from "Credentials" Manage API UI
      # * +:client_secret+ - Client Secret from "Credentials" Manage API UI
      # * +:access_token+ - Access Token from "Authorizations" Manage API UI
      # * +:headers_to_sign+ - List of headers (in order) that will be signed. This info is provided by individual APIs (default [])
      # * +:max_body+ - Maximum POST body size accepted.  This info is provided by individual APIs (default 2048)
      # * +:debug+ - Enable extra logging (default 'false')
      def setup_edgegrid(opts)
        @client_token = opts[:client_token]
        @client_secret = opts[:client_secret]
        @access_token = opts[:access_token]

        @headers_to_sign = opts[:headers_to_sign]
        @headers_to_sign ||= []

        @max_body = opts[:max_body]
        @max_body ||= 2048

        if opts[:debug]
          @log = Logger.new(STDERR)
        else
          @log = Logger.new('/dev/null')
        end
      end

      def setup_from_edgerc(opts)
	edgerc_path = opts[:filename] || File.expand_path('~/.edgerc')

        if File.exist?(edgerc_path) && @section
            file = IniFile.load(edgerc_path)
            data = file[@section]
            @client_token = data["client_token"]
            @client_secret =  data["client_secret"]
            @access_token = data["access_token"]
	    @max_body = data["max_body"] || 2048
            @headers_to_sign = opts[:headers_to_sign] || []
	end

        if opts[:debug]
          @log = Logger.new(STDERR)
        else
          @log = Logger.new('/dev/null')
        end
      end

      # Returns the computed Authorization header for the given request, timestamp and nonce
      def make_auth_header(request, timestamp, nonce)
        auth_header = "EG1-HMAC-SHA256 " + [
          "client_token" => @client_token,
          "access_token" => @access_token,
          "timestamp" => timestamp,
          "nonce" => nonce
        ].map {|kvp|
          kvp.keys.map { |k| k + "=" + kvp[k] }
        }.join(';') + ';'

        @log.debug("unsigned authorization header: #{auth_header}")

        signed_auth_header = auth_header + 'signature=' + sign_request(
          request, timestamp, auth_header
        )
        @log.debug("signed authorization header: #{signed_auth_header}")

        return signed_auth_header
      end

      # Same as Net::HTTP.request but with 'Authorization' header for {OPEN} Edgegrid added
      # to the given request
      def request(req, body=nil, &block)
        timestamp = self.class.eg_timestamp()
        nonce = self.class.new_nonce()
        req['Authorization'] = make_auth_header(req, timestamp, nonce)
        return orig_request(req, body, &block)
      end
    end
  end
end
