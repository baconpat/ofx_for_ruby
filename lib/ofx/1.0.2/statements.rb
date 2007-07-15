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
        def self.from_ofx_102_hash(balance_hash)
            balance = Balance.new
        
            balance.amount = balance_hash['BALAMT']
            balance.as_of = balance_hash['DTASOF'].to_datetime
            
            balance
        end
    end
    
    class Transaction
        def self.ofx_102_transaction_type_name_to_transaction_type(transaction_type_name)
            case transaction_type_name
                when 'CREDIT'       then :credit
                when 'DEBIT'        then :debit
                when 'INT'          then :interest
                when 'DIV'          then :dividend
                when 'FEE'          then :fee
                when 'SRVCHG'       then :service_charge
                when 'DEP'          then :deposit
                when 'ATM'          then :automated_teller_machine
                when 'POS'          then :point_of_sale
                when 'XFER'         then :transfer
                when 'CHECK'        then :check
                when 'PAYMENT'      then :electronic_payment
                when 'CASH'         then :cash_withdrawal
                when 'DIRECTDEP'    then :direct_deposit
                when 'DIRECTDEBIT'  then :direct_debit
                when 'REPEATPMT'    then :repeating_payment
                when 'OTHER'        then :other
                else raise NotImplementedError
            end
        end
    end
end