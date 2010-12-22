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

require File.dirname(__FILE__) + '/citi_helper'

class CitiSignupAccountInformationTest < Test::Unit::TestCase

    include CitiHelper

    def setup
        setup_citi_credentials
        setup_citi_accounts
    end

    def test_requesting_fresh_fi_profile_from_capital_one
        financial_institution = OFX::FinancialInstitution.get_institution('Citi')
        requestDocument = financial_institution.create_request_document

        client = OFX::FinancialClient.new([[OFX::FinancialInstitutionIdentification.new('Citigroup', '24909'),
                                            OFX::UserCredentials.new(@user_name, @password)]])
        requestDocument.message_sets << client.create_signon_request_message('24909')
        
        
        signup_message_set = OFX::SignupMessageSet.new
        account_info_request = OFX::AccountInformationRequest.new
        account_info_request.transaction_identifier = OFX::TransactionUniqueIdentifier.new
        account_info_request.date_of_last_account_update = DateTime.new(2001, 1, 1)
        signup_message_set.requests << account_info_request
        requestDocument.message_sets << signup_message_set
        

        response_document = financial_institution.send(requestDocument)
        assert response_document != nil

        verify_citi_header response_document
        
        assert_not_equal nil, response_document.message_sets
        assert_equal 2, response_document.message_sets.length
        
        verify_citi_signon_response response_document
        
        signup_message = response_document.message_sets[1]
        assert signup_message.kind_of?(OFX::SignupMessageSet)
        assert_equal 1, signup_message.responses.length
        account_info_response = signup_message.responses[0]
        assert account_info_response.kind_of?(OFX::AccountInformationResponse)
        assert_not_equal nil, account_info_response.transaction_identifier
        assert_not_equal nil, account_info_response.status
        assert account_info_response.status.kind_of?(OFX::Information)
        assert account_info_response.status.kind_of?(OFX::Success)
        assert_equal 0, account_info_response.status.code
        assert_equal :information, account_info_response.status.severity
        assert_equal nil, account_info_response.status.message
        
        assert_not_equal nil, account_info_response.date_of_last_account_update
        
        assert_not_equal nil, account_info_response.accounts
        assert_equal 1, account_info_response.accounts.length
        
        credit_card = account_info_response.accounts[0]
        assert_equal 'CREDIT CARD ************5398', credit_card.description
        assert_equal nil, credit_card.phone_number
        assert_not_equal nil, credit_card.account_information
        assert_not_equal nil, credit_card.account_information.account
        assert_equal @accounts[:credit_card], credit_card.account_information.account.account_identifier
        assert_equal true, credit_card.account_information.supports_transaction_detail_downloads
        assert_equal false, credit_card.account_information.transfer_source
        assert_equal false, credit_card.account_information.transfer_destination
        assert_equal :active, credit_card.account_information.status
    end
end