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

class CitiFinancialInstitutionProfileTest < Test::Unit::TestCase

    include CitiHelper

    def setup
        setup_citi_credentials
    end

    def test_requesting_fresh_fi_profile_from_citi
        financial_institution = OFX::FinancialInstitution.get_institution('Citi')
        requestDocument = financial_institution.create_request_document

        client = OFX::FinancialClient.new([[OFX::FinancialInstitutionIdentification.new('Citigroup', '24909'),
                                            OFX::UserCredentials.new(@user_name, @password)]])
        requestDocument.message_sets << client.create_signon_request_message('24909')
        
        client.date_of_last_profile_update = DateTime.new(2001, 1, 1)
        requestDocument.message_sets << client.create_profile_update_request_message()

        response_document = financial_institution.send(requestDocument)
        assert response_document != nil

        verify_citi_header response_document
        
        assert_not_equal nil, response_document.message_sets
        assert_equal 2, response_document.message_sets.length
        
        verify_citi_signon_response response_document
        
        profile_message = response_document.message_sets[1]
        assert profile_message.kind_of?(OFX::FinancialInstitutionProfileMessageSet)
        assert_equal 1, profile_message.responses.length
        profile_response = profile_message.responses[0]
        assert profile_response.kind_of?(OFX::FinancialInstitutionProfileResponse)
        assert_not_equal nil, profile_response.transaction_identifier
        assert_not_equal nil, profile_response.status
        assert profile_response.status.kind_of?(OFX::Information)
        assert profile_response.status.kind_of?(OFX::Success)
        assert_equal 0, profile_response.status.code
        assert_equal :information, profile_response.status.severity
        assert_equal nil, profile_response.status.message
        
        assert_not_equal nil, profile_response.date_of_last_profile_update
        assert_equal "Citigroup", profile_response.financial_institution_name
        assert_equal "8787 Baypine Road", profile_response.address
        assert_equal "Jacksonville", profile_response.city
        assert_equal "FL", profile_response.state
        assert_equal "32256", profile_response.postal_code
        assert_equal "USA", profile_response.country
        assert_equal "1-800-950-5114", profile_response.customer_service_telephone
        assert_equal "1-800-347-4934", profile_response.technical_support_telephone
        assert_equal nil, profile_response.facsimile_telephone
        assert_equal URI.parse("http://www.citicards.com"), profile_response.url
        assert_equal nil, profile_response.email_address
        
        
        
        assert_not_equal nil, profile_response.message_sets
        assert_equal 4, profile_response.message_sets.length
        
        # unsupported message sets
        assert_equal nil, profile_response.message_sets[OFX::BankingMessageSet]
        assert_equal nil, profile_response.message_sets[OFX::InvestmentStatementMessageSet]
        assert_equal nil, profile_response.message_sets[OFX::InterbankFundsTransferMessageSet]
        assert_equal nil, profile_response.message_sets[OFX::WireFundsTransferMessageSet]
        assert_equal nil, profile_response.message_sets[OFX::InvestmentSecurityListMessageSet]
        assert_equal nil, profile_response.message_sets[OFX::PaymentMessageSet]
        assert_equal nil, profile_response.message_sets[OFX::EmailMessageSet]   
        
        # signon
        assert_not_equal nil, profile_response.message_sets[OFX::SignonMessageSet]
        assert_equal 1, profile_response.message_sets[OFX::SignonMessageSet].length
        profile = profile_response.message_sets[OFX::SignonMessageSet][OFX::Version.new(1)]
        assert_not_equal nil, profile
        assert profile.kind_of?(OFX::SignonMessageSetProfile)
        assert_equal OFX::SignonMessageSet, profile.message_set_class
        assert_equal OFX::Version.new(1), profile.version
        assert_equal 'Intelidata', profile.service_provider_name
        assert_equal URI.parse('https://secureofx2.bankhost.com/citi/cgi-forte/ofx_rt?servicename=ofx_rt&pagename=ofx'), profile.message_url
        assert_equal 'NONE', profile.required_ofx_security
        assert_equal true, profile.requires_transport_security?
        assert_equal 'CITI-REALM', profile.signon_realm
        assert_equal 'ENG', profile.language
        assert_equal 'LITE', profile.synchronization_mode
        assert_equal true, profile.supports_response_file_error_recovery?
        
        # signup
        assert_not_equal nil, profile_response.message_sets[OFX::SignupMessageSet]
        assert_equal 1, profile_response.message_sets[OFX::SignupMessageSet].length
        profile = profile_response.message_sets[OFX::SignupMessageSet][OFX::Version.new(1)]
        assert_not_equal nil, profile
        assert profile.kind_of?(OFX::SignupMessageSetProfile)
        assert_equal OFX::SignupMessageSet, profile.message_set_class
        assert_equal OFX::Version.new(1), profile.version
        assert_equal 'Intelidata', profile.service_provider_name
        assert_equal URI.parse('https://secureofx2.bankhost.com/citi/cgi-forte/ofx_rt?servicename=ofx_rt&pagename=ofx'), profile.message_url
        assert_equal 'NONE', profile.required_ofx_security
        assert_equal true, profile.requires_transport_security?
        assert_equal 'CITI-REALM', profile.signon_realm
        assert_equal 'ENG', profile.language
        assert_equal 'LITE', profile.synchronization_mode
        assert_equal true, profile.supports_response_file_error_recovery
        assert_not_equal nil, profile.enrollment
        assert profile.enrollment.kind_of?(OFX::Enrollment)
        assert profile.enrollment.kind_of?(OFX::ClientEnrollment)
        assert_equal false, profile.enrollment.account_number_required
        assert_equal false, profile.user_information_changes_allowed?
        assert_equal true, profile.available_account_requests_allowed?
        assert_equal false, profile.service_activation_requests_allowed?

        # credit cards
        assert_not_equal nil, profile_response.message_sets[OFX::CreditCardStatementMessageSet]
        assert_equal 1, profile_response.message_sets[OFX::CreditCardStatementMessageSet].length
        profile = profile_response.message_sets[OFX::CreditCardStatementMessageSet][OFX::Version.new(1)]
        assert_not_equal nil, profile
        assert profile.kind_of?(OFX::CreditCardStatementMessageSetProfile)
        assert_equal OFX::CreditCardStatementMessageSet, profile.message_set_class
        assert_equal OFX::Version.new(1), profile.version
        assert_equal 'Intelidata', profile.service_provider_name
        assert_equal URI.parse('https://secureofx2.bankhost.com/citi/cgi-forte/ofx_rt?servicename=ofx_rt&pagename=ofx'), profile.message_url
        assert_equal 'NONE', profile.required_ofx_security
        assert_equal true, profile.requires_transport_security?
        assert_equal 'CITI-REALM', profile.signon_realm
        assert_equal 'ENG', profile.language
        assert_equal 'LITE', profile.synchronization_mode
        assert_equal true, profile.supports_response_file_error_recovery?
        assert_equal true, profile.closing_statement_available
        
        # profile
        assert_not_equal nil, profile_response.message_sets[OFX::FinancialInstitutionProfileMessageSet]
        assert_equal 1, profile_response.message_sets[OFX::FinancialInstitutionProfileMessageSet].length
        profile = profile_response.message_sets[OFX::FinancialInstitutionProfileMessageSet][OFX::Version.new(1)]
        assert_not_equal nil, profile
        assert profile.kind_of?(OFX::FinancialInstitutionProfileMessageSetProfile)
        assert_equal OFX::FinancialInstitutionProfileMessageSet, profile.message_set_class
        assert_equal OFX::Version.new(1), profile.version
        assert_equal 'Intelidata', profile.service_provider_name
        assert_equal URI.parse('https://secureofx2.bankhost.com/citi/cgi-forte/ofx_rt?servicename=ofx_rt&pagename=ofx'), profile.message_url
        assert_equal 'NONE', profile.required_ofx_security
        assert_equal true, profile.requires_transport_security?
        assert_equal 'CITI-REALM', profile.signon_realm
        assert_equal 'ENG', profile.language
        assert_equal 'LITE', profile.synchronization_mode
        assert_equal true, profile.supports_response_file_error_recovery?

        assert_not_equal nil, profile_response.signon_realms
        assert_equal 1, profile_response.signon_realms.length
        signon_realm = profile_response.signon_realms[0]
        assert_equal 'CITI-REALM', signon_realm.name
        assert_equal 6..32, signon_realm.password_length_constraint
        assert_equal :alphabetic_or_numeric, signon_realm.password_characters_constraint
        assert_equal false, signon_realm.case_sensitive
        assert_equal true, signon_realm.allows_special_characters
        assert_equal true, signon_realm.allows_spaces
        assert_equal false, signon_realm.supports_pin_changes
        assert_equal false, signon_realm.requires_initial_pin_change
    end
    
#    def test_requesting_up_to_date_fi_profile_from_citi
#        financial_institution = OFX::FinancialInstitution.get_institution('Capital One')
#        requestDocument = financial_institution.create_request_document
#
#        client = OFX::FinancialClient.new([[OFX::FinancialInstitutionIdentification.new('Hibernia', '1001'),
#                                            OFX::UserCredentials.new(@capitalOneUserName, @capitalOnePassword)]])
#        requestDocument.message_sets << client.create_signon_request_message('1001')
#        
#        client.date_of_last_profile_update = DateTime.now
#        requestDocument.message_sets << client.create_profile_update_request_message()
#
#        response_document = financial_institution.send(requestDocument)
#        assert response_document != nil
#
#        verify_citi_header response_document
#        
#        assert_not_equal nil, response_document.message_sets
#        assert_equal 2, response_document.message_sets.length
#        
#        verify_citi_signon_response response_document
#        
#        profile_message = response_document.message_sets[1]
#        assert profile_message.kind_of?(OFX::FinancialInstitutionProfileMessageSet)
#        assert_equal 1, profile_message.responses.length
#        profile_response = profile_message.responses[0]
#        assert profile_response.kind_of?(OFX::FinancialInstitutionProfileResponse)
#        assert_not_equal nil, profile_response.transaction_identifier
#        assert_not_equal nil, profile_response.status
#        assert profile_response.status.kind_of?(OFX::Information)
#        assert profile_response.status.kind_of?(OFX::ClientUpToDate)
#        assert_equal 1, profile_response.status.code
#        assert_equal :information, profile_response.status.severity
#        assert_not_equal nil, profile_response.status.message
#
#        assert_equal nil, profile_response.date_of_last_profile_update
#        assert_equal nil, profile_response.financial_institution_name
#        assert_equal nil, profile_response.address
#        assert_equal nil, profile_response.city
#        assert_equal nil, profile_response.state
#        assert_equal nil, profile_response.postal_code
#        assert_equal nil, profile_response.country
#        assert_equal nil, profile_response.customer_service_telephone
#        assert_equal nil, profile_response.technical_support_telephone
#        assert_equal nil, profile_response.facsimile_telephone
#        assert_equal nil, profile_response.url
#        assert_equal nil, profile_response.email_address
#        
#        assert_not_equal nil, profile_response.message_sets
#        assert_equal 0, profile_response.message_sets.length
#        
#        assert_not_equal nil, profile_response.signon_realms
#        assert_equal 0, profile_response.signon_realms.length
#    end
end