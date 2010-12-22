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

require File.dirname(__FILE__) + '/capital_one_helper'

class CapitalOneSignupAccountInformationTest < Test::Unit::TestCase

    include CapitalOneHelper

    def setup
        setup_capital_one_credentials
        setup_capital_one_accounts
    end

    def test_requesting_fresh_fi_profile_from_capital_one
        financial_institution = OFX::FinancialInstitution.get_institution('Capital One')
        requestDocument = financial_institution.create_request_document

        client = OFX::FinancialClient.new([[OFX::FinancialInstitutionIdentification.new('Hibernia', '1001'),
                                            OFX::UserCredentials.new(@user_name, @password)]])
        requestDocument.message_sets << client.create_signon_request_message('1001')
        
        
        signup_message_set = OFX::SignupMessageSet.new
        account_info_request = OFX::AccountInformationRequest.new
        account_info_request.transaction_identifier = OFX::TransactionUniqueIdentifier.new
        account_info_request.date_of_last_account_update = DateTime.new(2001, 1, 1)
        signup_message_set.requests << account_info_request
        requestDocument.message_sets << signup_message_set
        

        response_document = financial_institution.send(requestDocument)
        assert response_document != nil

        verify_capital_one_header response_document
        
        assert_not_equal nil, response_document.message_sets
        assert_equal 2, response_document.message_sets.length
        
        verify_capital_one_signon_response response_document
        
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
        assert_not_equal nil, account_info_response.status.message
        
        assert_not_equal nil, account_info_response.date_of_last_account_update
        
        assert_not_equal nil, account_info_response.accounts
        assert_equal 2, account_info_response.accounts.length
        
        checking = account_info_response.accounts[0]
        assert_equal 'VIP Free Interest Checking', checking.description
        assert_equal nil, checking.phone_number
        assert_not_equal nil, checking.account_information
        assert_not_equal nil, checking.account_information.account
        assert_equal '065002030', checking.account_information.account.bank_identifier
        assert_equal @accounts[:checking], checking.account_information.account.account_identifier
        assert_equal :checking, checking.account_information.account.account_type
        assert_equal true, checking.account_information.supports_transaction_detail_downloads
        assert_equal true, checking.account_information.transfer_source
        assert_equal true, checking.account_information.transfer_destination
        assert_equal :active, checking.account_information.status
        
        savings = account_info_response.accounts[1]
        assert_equal 'Regular Savings', savings.description
        assert_equal nil, savings.phone_number
        assert_not_equal nil, savings.account_information
        assert_not_equal nil, savings.account_information.account
        assert_equal '065002030', savings.account_information.account.bank_identifier
        assert_equal @accounts[:savings], savings.account_information.account.account_identifier
        assert_equal :savings, savings.account_information.account.account_type
        assert_equal true, savings.account_information.supports_transaction_detail_downloads
        assert_equal true, savings.account_information.transfer_source
        assert_equal true, savings.account_information.transfer_destination
        assert_equal :active, savings.account_information.status
    end
end