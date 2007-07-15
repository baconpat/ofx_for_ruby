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
        def ofx_102_message_set_name
            'CREDITCARD'
        end
        
        def request_or_response_from_ofx_102_tag_name(response_or_request_name)
            case response_or_request_name
                when "CCSTMTTRNRQ" then     CreditCardStatementRequest.new
                when "CCSTMTTRNRS" then     CreditCardStatementResponse.new
                when "CCSTMTENDTRNRQ" then  CreditCardClosingStatementRequest.new
                when "CCSTMTENDTRNRS" then  CreditCardClosingStatementResponse.new
                else                        raise NotImplementedError, response_or_request_name
            end
        end
        
        def self.from_ofx_102_hash(message_set_hash)
            message_set = CreditCardStatementMessageSet.new
            
            message_set_hash.each_pair() do |transaction_name, transaction_hash|
                case transaction_name
                    when "CCSTMTTRNRQ" then     message_set.requests << CreditCardStatementRequest.from_ofx_102_hash(transaction_hash)
                    when "CCSTMTTRNRS" then     message_set.responses << CreditCardStatementResponse.from_ofx_102_hash(transaction_hash)
                    when "CCSTMTENDTRNRQ" then  message_set.requests << CreditCardClosingStatementRequest.from_ofx_102_hash(transaction_hash)
                    when "CCSTMTENDTRNRS" then  message_set.responses << CreditCardClosingStatementResponse.from_ofx_102_hash(transaction_hash)
                    else                        raise NotImplementedError, transaction_name
                end
            end
            
            return message_set
        end
    end
    
    class CreditCardStatementMessageSetProfile < MessageSetProfile
        def self.from_ofx_102_hash(message_set_description_hash)
            profile = OFX::CreditCardStatementMessageSetProfile.new
            profile.message_set_class = OFX::CreditCardStatementMessageSet
            profile.from_ofx_102_hash(message_set_description_hash)
            
            profile.closing_statement_available = message_set_description_hash['CLOSINGAVAIL'] == 'Y'
            
            profile
        end
    end
    
    class CreditCardAccount
        def to_ofx_102_request_body
            "        <CCACCTFROM>\n" +
            "          <ACCTID>#{account_identifier}\n" +
            
            (account_key ? "          <ACCTKEY>#{account_key}\n" : "") +
            
            "        </CCACCTFROM>\n"
        end
        
        def self.from_ofx_102_hash(account_hash)
            account = OFX::BankingAccount.new
            
            account.account_identifier = account_hash['ACCTID']
            account.account_key = account_hash['ACCTKEY']
            
            account
        end
    end
    
    class CreditCardStatementRequest < TransactionalRequest
        def ofx_102_name
            'CCSTMT'
        end
        def ofx_102_request_body
            body = ""
            
            body += account.to_ofx_102_request_body
            
            body +=
            "        <INCTRAN>\n" +
            "          <INCLUDE>#{include_transactions.to_ofx_102_s}\n" if include_transactions
            
            body +=
            "          <DTSTART>#{included_range.begin.to_ofx_102_s}\n" +
            "          <DTEND>#{included_range.end.to_ofx_102_s}\n" if included_range
            
            body +=
            "        </INCTRAN>" if include_transactions
            
            body
        end
        
        def self.from_ofx_102_hash(transaction_hash)
            raise NotImplementedError
        end
    end
    
    class CreditCardStatementResponse < TransactionalResponse
        def ofx_102_name
            'CCSTMT'
        end
        
        def ofx_102_response_body
            raise NotImplementedError
        end
        
        def self.from_ofx_102_hash(transaction_hash)
            response = CreditCardStatementResponse.new
                       
            response.transaction_identifier = transaction_hash['TRNUID']
            response.status = OFX::Status.from_ofx_102_hash(transaction_hash['STATUS'])
            
            response_hash = transaction_hash['CCSTMTRS']
            return unless response_hash
            
            response.default_currency = response_hash['CURDEF']
            response.account = CreditCardAccount.from_ofx_102_hash(response_hash['CCACCTFROM'])
            
            response.marketing_information = response_hash['MKTGINFO']

            response.ledger_balance = Balance.from_ofx_102_hash(response_hash['LEDGERBAL']) if response_hash['LEDGERBAL']
            response.available_balance = Balance.from_ofx_102_hash(response_hash['AVAILBAL']) if response_hash['AVAILBAL']
            
            transaction_list_hash = response_hash['BANKTRANLIST']
            if (transaction_list_hash)
                response.transaction_range = transaction_list_hash['DTSTART'].to_datetime..transaction_list_hash['DTEND'].to_datetime
                
                response.transactions = []
                transactions = transaction_list_hash['STMTTRN'] if transaction_list_hash['STMTTRN'].kind_of?(Array)
                transactions = [transaction_list_hash['STMTTRN']] if transaction_list_hash['STMTTRN'].kind_of?(Hash)
                transactions = [] unless transactions
                
                transactions.each do |transaction_hash|
                    transaction = Transaction.new
                    
                    transaction.transaction_type = Transaction.ofx_102_transaction_type_name_to_transaction_type(transaction_hash['TRNTYPE'])
                    transaction.date_posted = transaction_hash['DTPOSTED'].to_datetime if transaction_hash['DTPOSTED']
                    transaction.date_initiated = transaction_hash['DTUSER'].to_datetime if transaction_hash['DTUSER']
                    transaction.date_available = transaction_hash['DTAVAIL'].to_datetime if transaction_hash['DTAVAIL']

                    transaction.amount = transaction_hash['TRNAMT'].to_d
                    transaction.currency = transaction_hash['CURRENCY'] || transaction_hash['ORIGCURRENCY'] || response.default_currency
        
                    transaction.financial_institution_transaction_identifier = transaction_hash['FITID']
                    transaction.corrected_financial_institution_transaction_identifier = transaction_hash['CORRECTFITID']
                    transaction.correction_action = case transaction_hash['CORRECT_ACTION']
                                                        when 'REPLACE' then :replace
                                                        when 'DELETE'  then :delete
                                                    end if transaction_hash['CORRECT_ACTION']
                    transaction.server_transaction_identifier = transaction_hash['SRVRTID']
                    transaction.check_number = transaction_hash['CHECKNUM']
                    transaction.reference_number = transaction_hash['REFNUM']
                            
                    transaction.standard_industrial_code = transaction_hash['SIC']
                    
                    transaction.payee_identifier = transaction_hash['PAYEEID']
                    if transaction_hash['PAYEE']
                        raise NotImplementedError
                    else
                        transaction.payee = transaction_hash['NAME']
                    end
                    
                    if (transaction_hash['BANKACCTTO'])
                        transaction.transfer_destination_account = BankingAccount.from_ofx_102_hash(transaction_hash['BANKACCTTO'])
                    elsif (transaction_hash['CCACCTTO'])
                        transaction.transfer_destination_account = CreditCardAccount.from_ofx_102_hash(transaction_hash['CCACCTTO'])
                    end
                    
                    transaction.memo = transaction_hash['MEMO']
                    
                    response.transactions << transaction
                end
            end
            
            response
        end
    end
    
    class CreditCardClosingStatementRequest < TransactionalRequest
        def ofx_102_name
            'CCSTMTEND'
        end
        def ofx_102_request_body
            body = ""
            
            body += account.to_ofx_102_request_body
                        
            body +=
            "        <DTSTART>#{statement_range.begin.to_ofx_102_s}\n" +
            "        <DTEND>#{statement_range.end.to_ofx_102_s}\n" if statement_range
            
            body
        end
        
        def self.from_ofx_102_hash(transaction_hash)
            raise NotImplementedError
        end
    end
    
    class CreditCardClosingStatementResponse < TransactionalResponse
        def ofx_102_name
            'CCSTMTEND'
        end
        
        def ofx_102_response_body
            raise NotImplementedError
        end
        
        def self.from_ofx_102_hash(transaction_hash)
            response = CreditCardClosingStatementResponse.new
                       
            response.transaction_identifier = transaction_hash['TRNUID']
            response.status = OFX::Status.from_ofx_102_hash(transaction_hash['STATUS'])
            
            response_hash = transaction_hash['CCSTMTENDRS']
            return unless response_hash
            
            response.default_currency = response_hash['CURDEF']
            response.account = CreditCardAccount.from_ofx_102_hash(response_hash['CCACCTFROM'])
            
            response.statements = []
            closings = response_hash['CCCLOSING'] if response_hash['CCCLOSING'].kind_of?(Array)
            closings = [response_hash['CCCLOSING']] if response_hash['CCCLOSING'].kind_of?(Hash)
            closings = [] unless closings
            closings.each do |closing_hash|
                statement = CreditCardClosingStatement.new
                
                statement.currency = closing_hash['CURRENCY'] || closing_hash['ORIGCURRENCY'] || response.default_currency
                
                statement.finanical_institution_transaction_identifier = closing_hash['FITID']
                statement.statement_range = closing_hash['DTOPEN'].to_date..closing_hash['DTCLOSE'].to_date
                statement.next_statement_close = closing_hash['DTNEXT'].to_date if closing_hash['DTNEXT']
        
                statement.opening_balance = closing_hash['BALOPEN'].to_d if closing_hash['BALOPEN']
                statement.closing_balance = closing_hash['BALCLOSE'].to_d if closing_hash['BALCLOSE']
                
                statement.payment_due_date = closing_hash['DTPMTDUE'].to_date if closing_hash['DTPMTDUE']
                statement.minimum_payment_due = closing_hash['MINPMTDUE'].to_d if closing_hash['MINPMTDUE']
        
                statement.finance_charge  = closing_hash['FINCHG'].to_d if closing_hash['FINCHG']
                statement.total_of_payments_and_charges  = closing_hash['PAYANDCREDIT'].to_d if closing_hash['PAYANDCREDIT']
                statement.total_of_purchases_and_advances  = closing_hash['PURANDADV'].to_d if closing_hash['PURANDADV']
                statement.debit_adjustements  = closing_hash['DEBADJ'].to_d if closing_hash['DEBADJ']
                statement.credit_limit  = closing_hash['CREDITLIMIT'].to_d if closing_hash['CREDITLIMIT']
                
                statement.transaction_range = closing_hash['DTPOSTSTART'].to_date..closing_hash['DTPOSTEND'].to_date
                
                statement.marketing_information = closing_hash['MKTGINFO']
                
                response.statements << statement
            end
            
            response
        end
    end
end