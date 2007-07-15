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
    class CreditCardStatementMessageSet < MessageSet
        def precedence
            4
        end
        def version
            1
        end
    end
    
    class CreditCardStatementMessageSetProfile < MessageSetProfile
        def self.message_set_class
            CreditCardStatementMessageSet
        end
        
        attr_accessor :closing_statement_available
        def closing_statement_available?
            closing_statement_available
        end
    end
    
    class CreditCardAccount
        attr_accessor :account_identifier
        attr_accessor :account_key
    end
    class CreditCardAccountInformation
        attr_accessor :account
        attr_accessor :supports_transaction_detail_downloads
        attr_accessor :transfer_source
        attr_accessor :transfer_destination
        attr_accessor :status
    end
    
    class CreditCardStatementRequest < TransactionalRequest
        attr_accessor :account
        attr_accessor :include_transactions
        def include_transactions?
            include_transactions
        end
        attr_accessor :included_range
    end
    class CreditCardStatementResponse < TransactionalResponse
        attr_accessor :default_currency
        attr_accessor :account
        attr_accessor :marketing_information
        
        attr_accessor :ledger_balance
        attr_accessor :available_balance
        
        attr_accessor :transaction_range
        attr_accessor :transactions
    end
    
    class CreditCardClosingStatementRequest < TransactionalRequest
        attr_accessor :account
        attr_accessor :statement_range
    end
    class CreditCardClosingStatementResponse < TransactionalResponse
        attr_accessor :default_currency
        attr_accessor :account
        
        attr_accessor :statements
    end
    class CreditCardClosingStatement
        attr_accessor :currency
        
        attr_accessor :finanical_institution_transaction_identifier
        attr_accessor :statement_range
        attr_accessor :next_statement_close

        attr_accessor :opening_balance
        attr_accessor :closing_balance
        
        attr_accessor :payment_due_date
        attr_accessor :minimum_payment_due

        attr_accessor :finance_charge
        attr_accessor :total_of_payments_and_charges
        attr_accessor :total_of_purchases_and_advances
        attr_accessor :debit_adjustements
        attr_accessor :credit_limit
        
        attr_accessor :transaction_range
        
        attr_accessor :marketing_information
    end
end