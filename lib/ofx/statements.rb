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
    class Balance
        attr_accessor :amount
        attr_accessor :as_of
    end
    
    class Transaction
        attr_accessor :transaction_type
        
        attr_accessor :date_posted
        attr_accessor :date_initiated
        attr_accessor :date_available
        
        attr_accessor :amount
        attr_accessor :currency
        
        attr_accessor :financial_institution_transaction_identifier
        attr_accessor :corrected_financial_institution_transaction_identifier
        attr_accessor :correction_action
        attr_accessor :server_transaction_identifier
        attr_accessor :check_number
        attr_accessor :reference_number
        
        attr_accessor :standard_industrial_code
        
        attr_accessor :payee_identifier
        attr_accessor :payee
        attr_accessor :transfer_destination_account
        
        attr_accessor :memo
    end
end