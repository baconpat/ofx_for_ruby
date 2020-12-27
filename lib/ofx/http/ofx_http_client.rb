# Copyright © 2007 Chris Guidry <chrisguidry@gmail.com>
#
# This file is part of OFX for Ruby.
# 
# OFX for Ruby is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
# 
# OFX for Ruby is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'net/http'
require 'net/https'
require 'uri'

module OFX
    class HTTPClient

        @ofx_uri = nil
        def initialize(ofx_uri)
            @ofx_uri = ofx_uri
        end

        def send(ofx_body, ssl_version=nil, do_print_request=false, do_print_response=false)
            http_request = Net::HTTP::Post.new(@ofx_uri.request_uri)

            http_request['User-Agent'] = "OFX for Ruby #{OFX::VERSION.to_dotted_s}"
            http_request['Content-Type'] = 'application/x-ofx'
            http_request['Accept'] = "*/*, application/x-ofx"
            http_request['Content-Length'] = ofx_body.length.to_s

            http_request.body = ofx_body.gsub("\n", "\r\n")

            if (do_print_request)
                print_request http_request
            end

            http = Net::HTTP.new(@ofx_uri.host, @ofx_uri.port)

            if (ssl_version)
                # supported in Ruby 1.9 or patched into 1.8
		if (Net::HTTP.method_defined?(:ssl_version=))
                    http.ssl_version=ssl_version
		end
            end
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER
            http.ca_file = File.join(File.dirname(__FILE__), "cacert.pem")
            http.use_ssl = true
            http_response = http.start do |http|
                http.request(http_request)
            end

            case http_response
                when Net::HTTPSuccess
                    print_response http_response if do_print_response
                    http_response.body
                else
                    print_response http_response
                    http_response.error!
            end
        end

        private
        def print_request(http_request)
            puts "Request:"
            puts @ofx_uri.host
            puts @ofx_uri.port
            puts @ofx_uri.path
            puts ""

            puts "Headers and Body:"
            http_request.each_header { |key, value| puts key + ": " + value + "\n" }
            puts "\n"
            puts http_request.body
        end

        def print_response(http_response)
            puts "Response:"
            puts http_response.http_version
            puts http_response.code.to_s + " " + http_response.message.to_s
            puts "Headers and Body:"
            http_response.each_header { |key, value| puts key + ": " + value + "\n" }
            puts "\n"
            puts http_response.body
        end
    end
end
