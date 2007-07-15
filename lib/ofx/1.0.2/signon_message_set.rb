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
    class SignonMessageSet < MessageSet
        def ofx_102_message_set_name
            'SIGNON'
        end
        
        def self.from_ofx_102_hash(message_set_hash)
            message_set = SignonMessageSet.new
            
            message_set_hash.each_pair() do |response_or_request_name, response_or_request_hash|
                case response_or_request_name
                    when "SONRQ" then   message_set.requests << SignonRequest.from_ofx_102_hash(response_or_request_hash)
                    when "SONRS" then   message_set.responses << SignonResponse.from_ofx_102_hash(response_or_request_hash)
                    else                raise NotImplementedError, response_or_request_name
                end
            end
            
            return message_set
        end
    end
    
    class SignonMessageSetProfile < MessageSetProfile
        def self.from_ofx_102_hash(message_set_description_hash)
            profile = OFX::SignonMessageSetProfile.new
            profile.message_set_class = OFX::SignonMessageSet
            profile.from_ofx_102_hash(message_set_description_hash)
            profile
        end
    end
    
    class SignonRequest < Request
        def ofx_102_name
            'SON'
        end
        def ofx_102_request_body
            "      <DTCLIENT>#{date.to_ofx_102_s}\n" +
            user_identification.to_ofx_102_s + "\n" +
            ("      <GENUSERKEY>#{generate_user_key}\n" if generate_user_key).to_s +
            "      <LANGUAGE>#{language}\n" +
            financial_institution_identification.to_ofx_102_s + "\n" +
            ("      <SESSCOOKIE>#{session_cookie}\n" if session_cookie).to_s +
            application_identification.to_ofx_102_s
        end
        def self.from_ofx_102_hash(request_hash)
            raise NotImplementedError
        end
    end
    class UserCredentials
        def to_ofx_102_s
            "      <USERID>#{user_identification}\n" +
            "      <USERPASS>#{password}"
        end
    end
    class UserKey
        def to_ofx_102_s
            "      <USERKEY>#{user_key}"
        end
    end

    class FinancialInstitutionIdentification
        def to_ofx_102_s
            "      <FI>\n" +
            "        <ORG>#{organization}\n" +
            "        <FID>#{financial_institution_identifier}\n" +
            "      </FI>"
        end
        def self.from_ofx_102_hash(fi_hash)
            return FinancialInstitutionIdentification.new(fi_hash['ORG'],
                                                          fi_hash['FID'])
        end
    end

    class ApplicationIdentification
        def to_ofx_102_s
            "      <APPID>#{application_identification}\n" +
            "      <APPVER>#{application_version}"
        end
    end
    
    class SignonResponse < Response
        def ofx_102_name
            'SON'
        end
        
        def ofx_102_response_body
            raise NotImplementedError
        end
        
        def self.from_ofx_102_hash(response_hash)
            response = SignonResponse.new
            
            response.status = OFX::Status.from_ofx_102_hash(response_hash['STATUS'])
            response.date = response_hash['DTSERVER'].to_datetime if response_hash['DTSERVER']
            #TODO: @user_key
            response.language = response_hash['LANGUAGE']
            response.date_of_last_profile_update = response_hash['DTPROFUP'].to_datetime if response_hash['DTPROFUP']
            response.date_of_last_account_update = response_hash['DTACCTUP'].to_datetime if response_hash['DTACCTUP']
            response.financial_institution_identification = OFX::FinancialInstitutionIdentification.from_ofx_102_hash(response_hash['FI'])
            #TODO: @session_cookie
            
            response
        end
    end
end