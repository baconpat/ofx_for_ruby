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

class CapitalOneFinancialInstitutionProfileTest < Test::Unit::TestCase

    include CapitalOneHelper

    def setup
        setup_capital_one_credentials
    end

    def test_requesting_fresh_fi_profile_from_capital_one
        financial_institution = OFX::FinancialInstitution.get_institution('Capital One')
        requestDocument = financial_institution.create_request_document

        client = OFX::FinancialClient.new([[OFX::FinancialInstitutionIdentification.new('Hibernia', '1001'),
                                            OFX::UserCredentials.new(@user_name, @password)]])
        requestDocument.message_sets << client.create_signon_request_message('1001')
        
        client.date_of_last_profile_update = DateTime.new(2001, 1, 1)
        requestDocument.message_sets << client.create_profile_update_request_message()

        response_document = financial_institution.send(requestDocument)
        assert response_document != nil

        verify_capital_one_header response_document
        
        assert_not_equal nil, response_document.message_sets
        assert_equal 2, response_document.message_sets.length
        
        verify_capital_one_signon_response response_document
        
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
        assert_not_equal nil, profile_response.status.message
        
        assert_not_equal nil, profile_response.date_of_last_profile_update
        assert_equal "Capital One Bank", profile_response.financial_institution_name
        assert_equal "PO Box 61540", profile_response.address
        assert_equal "New Orleans", profile_response.city
        assert_equal "LA", profile_response.state
        assert_equal "70161", profile_response.postal_code
        assert_equal "USA", profile_response.country
        assert_equal "1-877-442-3764", profile_response.customer_service_telephone
        assert_equal "1-877-442-3764", profile_response.technical_support_telephone
        assert_equal nil, profile_response.facsimile_telephone
        assert_equal URI.parse("https://onlinebanking.capitalone.com"), profile_response.url
        assert_equal "emailus@capitaloneinfo.com", profile_response.email_address
        
        
        
        assert_not_equal nil, profile_response.message_sets
        assert_equal 6, profile_response.message_sets.length
        
        # unsupported message sets
        assert_equal nil, profile_response.message_sets[OFX::CreditCardStatementMessageSet]
        assert_equal nil, profile_response.message_sets[OFX::InvestmentStatementMessageSet]
        assert_equal nil, profile_response.message_sets[OFX::InterbankFundsTransferMessageSet]
        assert_equal nil, profile_response.message_sets[OFX::WireFundsTransferMessageSet]
        assert_equal nil, profile_response.message_sets[OFX::InvestmentSecurityListMessageSet]
        
        # signon
        assert_not_equal nil, profile_response.message_sets[OFX::SignonMessageSet]
        assert_equal 1, profile_response.message_sets[OFX::SignonMessageSet].length
        profile = profile_response.message_sets[OFX::SignonMessageSet][OFX::Version.new(1)]
        assert_not_equal nil, profile
        assert profile.kind_of?(OFX::SignonMessageSetProfile)
        assert_equal OFX::SignonMessageSet, profile.message_set_class
        assert_equal OFX::Version.new(1), profile.version
        assert_equal 'Corillian Corporation', profile.service_provider_name
        assert_equal URI.parse('https://onlinebanking.capitalone.com/scripts/serverext.dll'), profile.message_url
        assert_equal 'NONE', profile.required_ofx_security
        assert_equal true, profile.requires_transport_security?
        assert_equal 'Realm1', profile.signon_realm
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
        assert_equal 'Corillian Corporation', profile.service_provider_name
        assert_equal URI.parse('https://onlinebanking.capitalone.com/scripts/serverext.dll'), profile.message_url
        assert_equal 'NONE', profile.required_ofx_security
        assert_equal true, profile.requires_transport_security?
        assert_equal 'Realm1', profile.signon_realm
        assert_equal 'ENG', profile.language
        assert_equal 'LITE', profile.synchronization_mode
        assert_equal true, profile.supports_response_file_error_recovery
        assert_not_equal nil, profile.enrollment
        assert profile.enrollment.kind_of?(OFX::Enrollment)
        assert profile.enrollment.kind_of?(OFX::WebEnrollment)
        assert_equal URI.parse('https://onlinebanking.capitalone.com'), profile.enrollment.url
        assert_equal false, profile.user_information_changes_allowed?
        assert_equal true, profile.available_account_requests_allowed?
        assert_equal false, profile.service_activation_requests_allowed?

        # banking
        assert_not_equal nil, profile_response.message_sets[OFX::BankingMessageSet]
        assert_equal 1, profile_response.message_sets[OFX::BankingMessageSet].length
        profile = profile_response.message_sets[OFX::BankingMessageSet][OFX::Version.new(1)]
        assert_not_equal nil, profile
        assert profile.kind_of?(OFX::BankingMessageSetProfile)
        assert_equal OFX::BankingMessageSet, profile.message_set_class
        assert_equal OFX::Version.new(1), profile.version
        assert_equal 'Corillian Corporation', profile.service_provider_name
        assert_equal URI.parse('https://onlinebanking.capitalone.com/scripts/serverext.dll'), profile.message_url
        assert_equal 'NONE', profile.required_ofx_security
        assert_equal true, profile.requires_transport_security?
        assert_equal 'Realm1', profile.signon_realm
        assert_equal 'ENG', profile.language
        assert_equal 'FULL', profile.synchronization_mode
        assert_equal true, profile.supports_response_file_error_recovery?
        assert_not_equal nil, profile.invalid_account_types
        assert_equal false, profile.closing_statement_available?

        assert_not_equal nil, profile.intrabank_transfer_profile
        assert_not_equal nil, profile.intrabank_transfer_profile.processing_days_off
        assert_equal 23, profile.intrabank_transfer_profile.processing_end_time_of_day.hour
        assert_equal 0, profile.intrabank_transfer_profile.processing_end_time_of_day.min
        assert_equal 0, profile.intrabank_transfer_profile.processing_end_time_of_day.sec
        assert_equal 0, profile.intrabank_transfer_profile.processing_end_time_of_day.offset
        assert_equal false, profile.intrabank_transfer_profile.supports_scheduled_transfers?
        assert_equal false, profile.intrabank_transfer_profile.supports_recurring_transfers?
        assert_equal false, profile.intrabank_transfer_profile.supports_modification_of_transfers?
        assert_equal false, profile.intrabank_transfer_profile.supports_modification_of_models?
        assert_equal 0, profile.intrabank_transfer_profile.model_window
        assert_equal 0, profile.intrabank_transfer_profile.number_of_days_early_funds_are_withdrawn
        assert_equal 0, profile.intrabank_transfer_profile.default_number_of_days_to_pay

        assert_equal nil, profile.stop_check_profile
#        assert_not_equal nil, profile.stop_check_profile.processing_days_off
#        assert_equal 23, profile.stop_check_profile.processing_end_time_of_day.hour
#        assert_equal 0, profile.stop_check_profile.processing_end_time_of_day.min
#        assert_equal 0, profile.stop_check_profile.processing_end_time_of_day.sec
#        assert_equal 0, profile.stop_check_profile.processing_end_time_of_day.offset
#        assert_equal false, profile.stop_check_profile.can_stop_a_range_of_checks?
#        assert_equal false, profile.stop_check_profile.can_stop_checks_by_description?
#        assert_equal '', profile.stop_check_profile.default_stop_check_fee

        assert_not_equal nil, profile.email_profile
        assert_equal true, profile.email_profile.supports_banking_email?
        assert_equal false, profile.email_profile.supports_notifications?
        

        # payments
        assert_not_equal nil, profile_response.message_sets[OFX::PaymentMessageSet]
        assert_equal 1, profile_response.message_sets[OFX::PaymentMessageSet].length
        profile = profile_response.message_sets[OFX::PaymentMessageSet][OFX::Version.new(1)]
        assert_not_equal nil, profile
        assert profile.kind_of?(OFX::PaymentMessageSetProfile)
        assert_equal OFX::PaymentMessageSet, profile.message_set_class
        assert_equal OFX::Version.new(1), profile.version
        assert_equal 'Corillian Corporation', profile.service_provider_name
        assert_equal URI.parse('https://onlinebanking.capitalone.com/scripts/serverext.dll'), profile.message_url
        assert_equal 'NONE', profile.required_ofx_security
        assert_equal true, profile.requires_transport_security?
        assert_equal 'Realm1', profile.signon_realm
        assert_equal 'ENG', profile.language
        assert_equal 'FULL', profile.synchronization_mode
        assert_equal true, profile.supports_response_file_error_recovery?

        # email
        assert_not_equal nil, profile_response.message_sets[OFX::EmailMessageSet]
        assert_equal 1, profile_response.message_sets[OFX::EmailMessageSet].length
        profile = profile_response.message_sets[OFX::EmailMessageSet][OFX::Version.new(1)]
        assert_not_equal nil, profile
        assert profile.kind_of?(OFX::EmailMessageSetProfile)
        assert_equal OFX::EmailMessageSet, profile.message_set_class
        assert_equal OFX::Version.new(1), profile.version
        assert_equal 'Corillian Corporation', profile.service_provider_name
        assert_equal URI.parse('https://onlinebanking.capitalone.com/scripts/serverext.dll'), profile.message_url
        assert_equal 'NONE', profile.required_ofx_security
        assert_equal true, profile.requires_transport_security?
        assert_equal 'Realm1', profile.signon_realm
        assert_equal 'ENG', profile.language
        assert_equal 'FULL', profile.synchronization_mode
        assert_equal true, profile.supports_response_file_error_recovery?
        assert_equal true, profile.supports_email?
        assert_equal false, profile.supports_mime_messages?
        
        # profile
        assert_not_equal nil, profile_response.message_sets[OFX::FinancialInstitutionProfileMessageSet]
        assert_equal 1, profile_response.message_sets[OFX::FinancialInstitutionProfileMessageSet].length
        profile = profile_response.message_sets[OFX::FinancialInstitutionProfileMessageSet][OFX::Version.new(1)]
        assert_not_equal nil, profile
        assert profile.kind_of?(OFX::FinancialInstitutionProfileMessageSetProfile)
        assert_equal OFX::FinancialInstitutionProfileMessageSet, profile.message_set_class
        assert_equal OFX::Version.new(1), profile.version
        assert_equal 'Corillian Corporation', profile.service_provider_name
        assert_equal URI.parse('https://onlinebanking.capitalone.com/scripts/serverext.dll'), profile.message_url
        assert_equal 'NONE', profile.required_ofx_security
        assert_equal true, profile.requires_transport_security?
        assert_equal 'Realm1', profile.signon_realm
        assert_equal 'ENG', profile.language
        assert_equal 'LITE', profile.synchronization_mode
        assert_equal true, profile.supports_response_file_error_recovery?

        assert_not_equal nil, profile_response.signon_realms
        assert_equal 1, profile_response.signon_realms.length
        signon_realm = profile_response.signon_realms[0]
        assert_equal 'Realm1', signon_realm.name
        assert_equal 8..12, signon_realm.password_length_constraint
        assert_equal :alphabetic_and_numeric, signon_realm.password_characters_constraint
        assert_equal true, signon_realm.case_sensitive
        assert_equal false, signon_realm.allows_special_characters
        assert_equal false, signon_realm.allows_spaces
        assert_equal true, signon_realm.supports_pin_changes
        assert_equal false, signon_realm.requires_initial_pin_change
    end
    
    def test_requesting_up_to_date_fi_profile_from_capital_one
        financial_institution = OFX::FinancialInstitution.get_institution('Capital One')
        requestDocument = financial_institution.create_request_document

        client = OFX::FinancialClient.new([[OFX::FinancialInstitutionIdentification.new('Hibernia', '1001'),
                                            OFX::UserCredentials.new(@user_name, @password)]])
        requestDocument.message_sets << client.create_signon_request_message('1001')
        
        client.date_of_last_profile_update = DateTime.now
        requestDocument.message_sets << client.create_profile_update_request_message()

        response_document = financial_institution.send(requestDocument)
        assert response_document != nil

        verify_capital_one_header response_document
        
        assert_not_equal nil, response_document.message_sets
        assert_equal 2, response_document.message_sets.length
        
        verify_capital_one_signon_response response_document
        
        profile_message = response_document.message_sets[1]
        assert profile_message.kind_of?(OFX::FinancialInstitutionProfileMessageSet)
        assert_equal 1, profile_message.responses.length
        profile_response = profile_message.responses[0]
        assert profile_response.kind_of?(OFX::FinancialInstitutionProfileResponse)
        assert_not_equal nil, profile_response.transaction_identifier
        assert_not_equal nil, profile_response.status
        assert profile_response.status.kind_of?(OFX::Information)
        assert profile_response.status.kind_of?(OFX::ClientUpToDate)
        assert_equal 1, profile_response.status.code
        assert_equal :information, profile_response.status.severity
        assert_not_equal nil, profile_response.status.message

        assert_equal nil, profile_response.date_of_last_profile_update
        assert_equal nil, profile_response.financial_institution_name
        assert_equal nil, profile_response.address
        assert_equal nil, profile_response.city
        assert_equal nil, profile_response.state
        assert_equal nil, profile_response.postal_code
        assert_equal nil, profile_response.country
        assert_equal nil, profile_response.customer_service_telephone
        assert_equal nil, profile_response.technical_support_telephone
        assert_equal nil, profile_response.facsimile_telephone
        assert_equal nil, profile_response.url
        assert_equal nil, profile_response.email_address
        
        assert_not_equal nil, profile_response.message_sets
        assert_equal 0, profile_response.message_sets.length
        
        assert_not_equal nil, profile_response.signon_realms
        assert_equal 0, profile_response.signon_realms.length
    end
end