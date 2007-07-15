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

module OFX
    class MessageSet
        def to_ofx_102_s
            request_message = requests.length > 0
            request_message = responses.length == 0

            message = ''
            
            if request_message
                message += "  <#{ofx_102_message_set_name}MSGSRQV#{version}>\n"
                requests.each do |request|
                    message += request.to_ofx_102_s + "\n"
                end
                message += "  </#{ofx_102_message_set_name}MSGSRQV#{version}>\n"
            else
                message += "  <#{ofx_102_message_set_name}MSGSRSV#{version}>\n"
                responses.each do |response|
                    message += response.to_ofx_102_s + "\n"
                end
                message += "  </#{ofx_102_message_set_name}MSGSRSV#{version}>\n"
            end
                
            message
        end

        def ofx_102_message_set_name
            raise NotImplementedError
        end
        
        def self.from_ofx_102_message_set_hash(message_set_name, message_set_hash)
            match = /^(\w+)MSGSR([QS])V(\d+)$/.match(message_set_name)
            raise NotImplementedError unless match
            
            message_set_class = MESSAGE_SET_NAMES_TO_CLASSES[$1]
            raise NotImplementedError unless message_set_class
            
            return message_set_class.from_ofx_102_hash(message_set_hash)
        end
        
        def request_or_response_from_ofx_102_tag_name(response_or_request_name)
            raise NotImplementedError
        end
        
        private
        MESSAGE_SET_NAMES_TO_CLASSES = 
        {
            'SIGNON'        => SignonMessageSet,
            'SIGNUP'        => SignupMessageSet,
            'PROF'          => FinancialInstitutionProfileMessageSet,
            'BANK'          => BankingMessageSet,
            'CREDITCARD'    => CreditCardStatementMessageSet
        }
    end
    
    class MessageSetProfile        
        def from_ofx_102_hash(message_set_description_hash)           
            message_set_core_hash = message_set_description_hash['MSGSETCORE']
            @version = OFX::Version.new(message_set_core_hash['VER'])
            @service_provider_name = message_set_core_hash['SPNAME']
            @message_url = URI.parse(message_set_core_hash['URL']) if message_set_core_hash['URL']
            @required_ofx_security = message_set_core_hash['OFXSEC']
            @requires_transport_security = message_set_core_hash['TRANSPSEC'] == 'Y' ? true : false
            @signon_realm = message_set_core_hash['SIGNONREALM']
            @language = message_set_core_hash['LANGUAGE']
            @synchronization_mode = message_set_core_hash['SYNCMODE']
            @supports_response_file_error_recovery = message_set_core_hash['RESPFILEER'] == 'Y' ? true : false
        end
    end

    class Request
        def to_ofx_102_s
            request = ''
            request += "    <#{ofx_102_name}RQ>\n"

            request += ofx_102_request_body + "\n"

            request += "    </#{ofx_102_name}RQ>"
            request
        end

        def ofx_102_request_body
            raise NotImplementedError
        end
    end

    class TransactionalRequest < Request
        def to_ofx_102_s
            request = ''
            request += "    <#{ofx_102_name}TRNRQ>\n"

            request += "      <TRNUID>#{transaction_identifier}\n"
            request += "      <CLTCOOKIE>#{client_cookie}\n" if client_cookie
            request += "      <TAN>#{transaction_authorization_number}\n" if transaction_authorization_number

            request += "      <#{ofx_102_name}RQ>\n"

            request += ofx_102_request_body + "\n"

            request += "      </#{ofx_102_name}RQ>\n"

            request += "    </#{ofx_102_name}TRNRQ>"
            request
        end

        def ofx_102_request_body
            raise NotImplementedError
        end
    end
    
    class Response
        def to_ofx_102_s
            response = ''
            response += "    <#{ofx_102_name}RS>\n"

            response += ofx_102_response_body + "\n"

            response += "    </#{ofx_102_name}RS>"
            response
        end

        def ofx_102_response_body
            raise NotImplementedError
        end
    end

    class TransactionalResponse < Response
        def to_ofx_102_s
            response = ''
            response += "    <#{ofx_102_name}TRNRS>\n"

            response += "      <TRNUID>#{transaction_identifier}\n"
            response += "      <CLTCOOKIE>#{client_cookie}\n" if client_cookie

            response += "      <#{ofx_102_name}RS>\n"

            response += ofx_102_response_body + "\n"

            response += "      </#{ofx_102_name}RS>\n"

            response += "    </#{ofx_102_name}TRNRS>"
            response
        end

        def ofx_102_response_body
            raise NotImplementedError
        end
    end
end