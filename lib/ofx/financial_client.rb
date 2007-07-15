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

require 'date'

module OFX
    class FinancialClient

        @financial_institutions_and_credentials = []
        
        attr_accessor :date_of_last_profile_update

        def initialize(financial_institutions_and_credentials)
            @financial_institutions_and_credentials = financial_institutions_and_credentials
        end

        def financial_institution_identification_for(financial_institution_id)
            @financial_institutions_and_credentials.each do |pair|
                return pair[0] if (pair[0].financial_institution_identifier == financial_institution_id)
            end
            return nil
        end
        def user_identification_for(financial_institution_id)
            @financial_institutions_and_credentials.each do |pair|
                return pair[1] if (pair[0].financial_institution_identifier == financial_institution_id)
            end
            return nil
        end

        def application_identification
            OFX::ApplicationIdentification.new('OFX', '0010')
        end

        def create_signon_request_message(financial_institution_id)
            signonMessageSet = OFX::SignonMessageSet.new

            signonRequest = OFX::SignonRequest.new
            signonRequest.date = DateTime.now
            signonRequest.user_identification = self.user_identification_for(financial_institution_id)
            signonRequest.generate_user_key = false
            signonRequest.language = "ENG"
            signonRequest.financial_institution_identification = self.financial_institution_identification_for(financial_institution_id)
            signonRequest.session_cookie = nil
            signonRequest.application_identification = self.application_identification
            signonMessageSet.requests << signonRequest

            signonMessageSet
        end
        
        def create_profile_update_request_message()
            profileMessageSet = OFX::FinancialInstitutionProfileMessageSet.new
            
            profileRequest = OFX::FinancialInstitutionProfileRequest.new
            profileRequest.transaction_identifier = OFX::TransactionUniqueIdentifier.new
            profileRequest.client_routing = 'MSGSET'
            profileRequest.date_of_last_profile_update = self.date_of_last_profile_update
            profileMessageSet.requests << profileRequest
            
            profileMessageSet
        end
    end
end