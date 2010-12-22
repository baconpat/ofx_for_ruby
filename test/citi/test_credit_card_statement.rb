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

class CitiCreditCardStatmentTest < Test::Unit::TestCase

    include CitiHelper

    def setup
        setup_citi_credentials
        setup_citi_accounts
    end

    def test_requesting_last_seven_days_statement_from_citi
        financial_institution = OFX::FinancialInstitution.get_institution('Citi')
        requestDocument = financial_institution.create_request_document

        client = OFX::FinancialClient.new([[OFX::FinancialInstitutionIdentification.new('Citigroup', '24909'),
                                            OFX::UserCredentials.new(@user_name, @password)]])
        requestDocument.message_sets << client.create_signon_request_message('24909')        

        cc_message_set = OFX::CreditCardStatementMessageSet.new
        statement_request = OFX::CreditCardStatementRequest.new
        
        statement_request.transaction_identifier = OFX::TransactionUniqueIdentifier.new
        statement_request.account = OFX::CreditCardAccount.new
        statement_request.account.account_identifier = @accounts[:credit_card]
        
        statement_request.include_transactions = true
        statement_request.included_range = nil
        
        cc_message_set.requests << statement_request
        requestDocument.message_sets << cc_message_set

        response_document = financial_institution.send(requestDocument)
        assert response_document != nil

        verify_citi_header response_document
        
        assert_not_equal nil, response_document.message_sets
        assert_equal 2, response_document.message_sets.length
        
        verify_citi_signon_response response_document
        
        cc_message_set = response_document.message_sets[1]
        assert_not_equal nil, cc_message_set
        assert cc_message_set.kind_of?(OFX::CreditCardStatementMessageSet)
        assert_equal 1, cc_message_set.responses.length
        statement = cc_message_set.responses[0]
        assert_not_equal nil, statement
        assert_equal 'USD', statement.default_currency
        assert_not_equal nil, statement.account
        assert_equal @accounts[:credit_card], statement.account.account_identifier
        
        assert_equal nil, statement.marketing_information

        assert_not_equal nil, statement.ledger_balance
        assert_not_equal nil, statement.ledger_balance.amount
        assert_not_equal nil, statement.ledger_balance.as_of
        
        assert_not_equal nil, statement.available_balance
        assert_not_equal nil, statement.available_balance.amount
        assert_not_equal nil, statement.available_balance.as_of

        assert_not_equal nil, statement.transaction_range
        assert_not_equal nil, statement.transaction_range.begin
        assert_not_equal nil, statement.transaction_range.end
        assert_not_equal nil, statement.transactions

        statement.transactions.each do |transaction|
            assert_not_equal nil, transaction.transaction_type
            assert_not_equal nil, transaction.date_posted
            assert_not_equal nil, transaction.amount
            assert transaction.amount != 0.0.to_d
            assert_not_equal nil, transaction.financial_institution_transaction_identifier
            assert_not_equal nil, transaction.standard_industrial_code
        end
    end
    
    def test_requesting_closing_statement_from_citi
        financial_institution = OFX::FinancialInstitution.get_institution('Citi')
        requestDocument = financial_institution.create_request_document

        client = OFX::FinancialClient.new([[OFX::FinancialInstitutionIdentification.new('Citigroup', '24909'),
                                            OFX::UserCredentials.new(@user_name, @password)]])
        requestDocument.message_sets << client.create_signon_request_message('24909')        

        cc_message_set = OFX::CreditCardStatementMessageSet.new
        statement_request = OFX::CreditCardClosingStatementRequest.new
        
        statement_request.transaction_identifier = OFX::TransactionUniqueIdentifier.new
        statement_request.account = OFX::CreditCardAccount.new
        statement_request.account.account_identifier = @accounts[:credit_card]
        
        cc_message_set.requests << statement_request
        requestDocument.message_sets << cc_message_set

        response_document = financial_institution.send(requestDocument)
        assert response_document != nil

        verify_citi_header response_document
        
        assert_not_equal nil, response_document.message_sets
        assert_equal 2, response_document.message_sets.length
        
        verify_citi_signon_response response_document
        
        cc_message_set = response_document.message_sets[1]
        assert_not_equal nil, cc_message_set
        assert_equal 1, cc_message_set.responses.length
        statement = cc_message_set.responses[0]
        assert_not_equal nil, statement
        assert_equal 'USD', statement.default_currency
        assert_not_equal nil, statement.account
        assert_equal @accounts[:credit_card], statement.account.account_identifier
        
        assert_not_equal nil, statement.statements
        assert_not_equal 0, statement.statements.length
        statement.statements.each do |closing|
            assert_equal 'USD', closing.currency
            
            assert_not_equal nil, closing.finanical_institution_transaction_identifier
            assert_not_equal nil, closing.statement_range
            assert_equal nil, closing.next_statement_close
            
            assert_equal nil, closing.opening_balance
            assert_not_equal nil, closing.closing_balance
            
            assert_not_equal nil, closing.payment_due_date
            assert_not_equal nil, closing.minimum_payment_due
            
            assert_equal nil, closing.finance_charge
            assert_equal nil, closing.total_of_payments_and_charges
            assert_equal nil, closing.total_of_purchases_and_advances
            assert_equal nil, closing.debit_adjustements
            assert_not_equal nil, closing.credit_limit
            assert_not_equal 0.0.to_d, closing.credit_limit
            
            assert_not_equal nil, closing.transaction_range
            
            assert_equal nil, closing.marketing_information
        end
    end
end