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

require File.dirname(__FILE__) + '/document'
require File.dirname(__FILE__) + '/header'
require File.dirname(__FILE__) + '/message_set'
require File.dirname(__FILE__) + '/status'
require File.dirname(__FILE__) + '/statements'

require File.dirname(__FILE__) + '/signon_message_set'
require File.dirname(__FILE__) + '/signup_message_set'
require File.dirname(__FILE__) + '/banking_message_set'
require File.dirname(__FILE__) + '/credit_card_statement_message_set'
require File.dirname(__FILE__) + '/investment_statement_message_set'
require File.dirname(__FILE__) + '/interbank_funds_transfer_message_set'
require File.dirname(__FILE__) + '/wire_funds_transfer_message_set'
require File.dirname(__FILE__) + '/payment_message_set'
require File.dirname(__FILE__) + '/email_message_set'
require File.dirname(__FILE__) + '/investment_security_list_message_set'
require File.dirname(__FILE__) + '/financial_institution_profile_message_set'

require File.dirname(__FILE__) + '/parser'

module OFX
    module OFX102
        class Serializer
            def to_http_post_body(document)
                body = ""

                body += document.header.to_ofx_102_s
                body += "\n"
                body += "<OFX>\n"
                document.message_sets.each do |message_set|
                    body += message_set.to_ofx_102_s
                end
                body += "</OFX>\n"
                
                #print body

                body
            end

            def from_http_response_body(body)
                header_pattern = /(\w+\:.*\n)+/
                header_match = header_pattern.match(body)
                
                body = header_match.post_match
                header = Header.from_ofx_102_s(header_match[0].strip)
            
                parser = OFX::OFX102::Parser.new
                parser.scan_str body
                
                if parser.documents.length > 1
                    raise NotImplementedError, "Multiple response documents"
                end
                
                #require 'pp'
                #print body
                #pp parser.ofx_hashes[0]
                
                document = parser.documents[0]
                document.header = header
                document
            end
        end
    end
end

require 'date'
class Date
    def to_ofx_102_s
        strftime('%Y%m%d')
    end
end
class DateTime
    def to_ofx_102_s
        strftime('%Y%m%d%H%M%S')
    end
end
class String
    def to_date
        Date.parse(self)
    end
    def to_datetime
        DateTime.parse(self)
    end
    def to_time
        ('-47120101' + self).to_datetime
    end
end
class TrueClass
    def to_ofx_102_s
        'Y'
    end
end
class FalseClass
    def to_ofx_102_s
        'Y'
    end
end
