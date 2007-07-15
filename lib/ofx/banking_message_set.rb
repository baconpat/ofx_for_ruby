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
    class BankingMessageSet < MessageSet
        def precedence
            3
        end
        def version
            1
        end
    end
    
    class BankingMessageSetProfile < MessageSetProfile
        def self.message_set_class
            OFX::BankingMessageSet
        end
        
        attr_accessor :invalid_account_types
        attr_accessor :closing_statement_available
        def closing_statement_available?
            closing_statement_available
        end

        attr_accessor :intrabank_transfer_profile
        attr_accessor :stop_check_profile
        attr_accessor :email_profile
    end
    class IntrabankTransferProfile
        attr_accessor :processing_days_off
        attr_accessor :processing_end_time_of_day
        attr_accessor :supports_scheduled_transfers
        def supports_scheduled_transfers?
            supports_scheduled_transfers
        end
        attr_accessor :supports_recurring_transfers
        def supports_recurring_transfers?
            supports_recurring_transfers
        end
        attr_accessor :supports_modification_of_transfers
        def supports_modification_of_transfers?
            supports_modification_of_transfers
        end
        attr_accessor :supports_modification_of_models
        def supports_modification_of_models?
            supports_modification_of_models
        end
        attr_accessor :model_window
        attr_accessor :number_of_days_early_funds_are_withdrawn
        attr_accessor :default_number_of_days_to_pay
    end
    class StopCheckProfile
        attr_accessor :processing_days_off
        attr_accessor :processing_end_time_of_day
        attr_accessor :can_stop_a_range_of_checks
        def can_stop_a_range_of_checks?
            can_stop_a_range_of_checks
        end
        attr_accessor :can_stop_checks_by_description
        def can_stop_checks_by_description?
            can_stop_checks_by_description
        end
        attr_accessor :default_stop_check_fee
    end
    class BankingEmailProfile
        attr_accessor :supports_banking_email
        def supports_banking_email?
            supports_banking_email
        end
        attr_accessor :supports_notifications
        def supports_notifications?
            supports_notifications
        end
    end
    
    class BankingAccount
        attr_accessor :bank_identifier
        attr_accessor :branch_identifier
        attr_accessor :account_identifier
        attr_accessor :account_type
        attr_accessor :account_key
    end
    class BankingAccountInformation
        attr_accessor :account
        attr_accessor :supports_transaction_detail_downloads
        attr_accessor :transfer_source
        attr_accessor :transfer_destination
        attr_accessor :status
    end
    
    
    class BankingStatementRequest < TransactionalRequest
        attr_accessor :account
        attr_accessor :include_transactions
        def include_transactions?
            include_transactions
        end
        attr_accessor :included_range
    end
    class BankingStatementResponse < TransactionalResponse
        attr_accessor :default_currency
        attr_accessor :account
        attr_accessor :marketing_information
        
        attr_accessor :ledger_balance
        attr_accessor :available_balance
        
        attr_accessor :transaction_range
        attr_accessor :transactions
    end
end