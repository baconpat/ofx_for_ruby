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

class CapitalOneBankingStatmentTest < Test::Unit::TestCase

    include CapitalOneHelper

    def setup
        setup_capital_one_credentials
        setup_capital_one_accounts
    end

    def test_requesting_last_seven_days_statement_from_capital_one
        financial_institution = OFX::FinancialInstitution.get_institution('Capital One')
        requestDocument = financial_institution.create_request_document

        client = OFX::FinancialClient.new([[OFX::FinancialInstitutionIdentification.new('Hibernia', '1001'),
                                            OFX::UserCredentials.new(@user_name, @password)]])
        requestDocument.message_sets << client.create_signon_request_message('1001')
        
               
        banking_message_set = OFX::BankingMessageSet.new
        statement_request = OFX::BankingStatementRequest.new
        
        statement_request.transaction_identifier = OFX::TransactionUniqueIdentifier.new
        statement_request.account = OFX::BankingAccount.new
        statement_request.account.bank_identifier = '065002030'
        statement_request.account.branch_identifier = nil
        statement_request.account.account_identifier = @accounts[:checking]
        statement_request.account.account_type = :checking
        statement_request.account.account_key = nil
        
        statement_request.include_transactions = true
        statement_request.included_range = ('2007-06-01'.to_date)..('2007-06-07'.to_date)
        
        banking_message_set.requests << statement_request
        requestDocument.message_sets << banking_message_set

        response_document = financial_institution.send(requestDocument)
        assert response_document != nil

        verify_capital_one_header response_document
        
        assert_not_equal nil, response_document.message_sets
        assert_equal 2, response_document.message_sets.length
        
        verify_capital_one_signon_response response_document
        
        banking_message_set = response_document.message_sets[1]
        assert_not_equal nil, banking_message_set
        assert banking_message_set.kind_of?(OFX::BankingMessageSet)
        assert_equal 1, banking_message_set.responses.length
        statement = banking_message_set.responses[0]
        assert_not_equal nil, statement
        assert_equal 'USD', statement.default_currency
        assert_not_equal nil, statement.account
        assert_equal '065002030', statement.account.bank_identifier
        assert_equal @accounts[:checking], statement.account.account_identifier
        assert_equal :checking, statement.account.account_type
        
        assert_equal nil, statement.marketing_information

        assert_not_equal nil, statement.ledger_balance
        assert_not_equal nil, statement.ledger_balance.amount
        assert_not_equal nil, statement.ledger_balance.as_of
        
        assert_not_equal nil, statement.available_balance
        assert_not_equal nil, statement.available_balance.amount
        assert_not_equal nil, statement.available_balance.as_of

        assert_not_equal nil, statement.transaction_range
        assert_equal '2007-06-01'.to_date, statement.transaction_range.begin
        assert_equal '2007-06-07'.to_date, statement.transaction_range.end
        assert_not_equal nil, statement.transactions
        assert_equal 18, statement.transactions.length
        
        padded_range = (statement.transaction_range.begin - 1.day)..(statement.transaction_range.end + 1.day)
        total_of_transactions = 0.0.to_d
        statement.transactions.each do |transaction|
            assert_not_equal nil, transaction.transaction_type
            assert_not_equal nil, transaction.date_posted
            assert_not_equal nil, transaction.amount
            assert_not_equal nil, transaction.financial_institution_transaction_identifier
        
            assert padded_range === transaction.date_posted

            total_of_transactions += transaction.amount
        end
        
        assert_equal 366.15.to_d, total_of_transactions
    end
end