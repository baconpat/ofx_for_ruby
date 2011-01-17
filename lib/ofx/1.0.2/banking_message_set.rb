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
        def ofx_102_message_set_name
            'BANK'
        end
        
        def request_or_response_from_ofx_102_tag_name(response_or_request_name)
            case response_or_request_name
                when "STMTTRNRQ" then   BankingStatementRequest.new
                when "STMTTRNRS" then   BankingStatementResponse.new
                else                    raise NotImplementedError, response_or_request_name
            end
        end
        
        def self.from_ofx_102_hash(message_set_hash)
            message_set = BankingMessageSet.new
            
            message_set_hash.each_pair() do |transaction_name, transaction_hash|
                case transaction_name
                    when "STMTTRNRQ" then       message_set.requests << BankingStatementRequest.from_ofx_102_hash(transaction_hash)
                    when "STMTTRNRS" then       message_set.responses << BankingStatementResponse.from_ofx_102_hash(transaction_hash)
                    else                        raise NotImplementedError, transaction_name
                end
            end
            
            return message_set
        end
    end
    
    class BankingMessageSetProfile < MessageSetProfile
        def self.from_ofx_102_hash(message_set_description_hash)
            profile = OFX::BankingMessageSetProfile.new
            profile.message_set_class = OFX::BankingMessageSet
            profile.from_ofx_102_hash(message_set_description_hash)
            
            profile.invalid_account_types = []
            if message_set_description_hash['INVALIDACCTTYPE']
                message_set_description_hash['INVALIDACCTTYPE'].each do |invalid_acct_type|
                    profile.invalid_account_types << BankingAccount.ofx_102_s_to_account_type(invalid_acct_type)
                end
            end
            
            profile.closing_statement_available = message_set_description_hash['CLOSINGAVAIL'] == 'Y'
    
            intrabank_profile_hash = message_set_description_hash['XFERPROF']
            if (intrabank_profile_hash)
                profile.intrabank_transfer_profile = OFX::IntrabankTransferProfile.new
                
                days_off = intrabank_profile_hash['PROCDAYSOFF']
                profile.intrabank_transfer_profile.processing_days_off = []
                if days_off
                    days_off.each { |day| profile.intrabank_transfer_profile.processing_days_off << day }
                end
                profile.intrabank_transfer_profile.processing_end_time_of_day = intrabank_profile_hash['PROCENDTM'].to_time if intrabank_profile_hash['PROCENDTM']
                profile.intrabank_transfer_profile.supports_scheduled_transfers = intrabank_profile_hash['CANSCHED'] == 'Y'
                profile.intrabank_transfer_profile.supports_recurring_transfers = intrabank_profile_hash['CANRECUR'] == 'Y'
                profile.intrabank_transfer_profile.supports_modification_of_transfers = intrabank_profile_hash['CANMODXFERS'] == 'Y'
                profile.intrabank_transfer_profile.supports_modification_of_models = intrabank_profile_hash['CANMODMDLS'] == 'Y'
                profile.intrabank_transfer_profile.model_window = intrabank_profile_hash['MODELWND'].to_i
                profile.intrabank_transfer_profile.number_of_days_early_funds_are_withdrawn = intrabank_profile_hash['DAYSWITH'].to_i
                profile.intrabank_transfer_profile.default_number_of_days_to_pay = intrabank_profile_hash['DFLTDAYSTOPAY'].to_i
            end

            stop_check_profile_hash = message_set_description_hash['STPCHKPROF']
            if (stop_check_profile_hash)
                profile.stop_check_profile = OFX::StopCheckProfile.new
                
                days_off = stop_check_profile_hash['PROCDAYSOFF']
                profile.stop_check_profile.processing_days_off = []
                if days_off
                    days_off.each { |day| profile.stop_check_profile.processing_days_off << day }
                end
                profile.stop_check_profile.processing_end_time_of_day = stop_check_profile_hash['PROCENDTM'].to_time if stop_check_profile_hash['PROCENDTM']
                profile.stop_check_profile.can_stop_a_range_of_checks = stop_check_profile_hash['CANUSERANGE'] == 'Y'
                profile.stop_check_profile.can_stop_checks_by_description = stop_check_profile_hash['CANUSEDESC'] == 'Y'
                profile.stop_check_profile.default_stop_check_fee = stop_check_profile_hash['STPCHKFEE']
            end

            email_profile_hash = message_set_description_hash['EMAILPROF']
            if (email_profile_hash)
                profile.email_profile = OFX::BankingEmailProfile.new
                profile.email_profile.supports_banking_email = email_profile_hash['CANEMAIL'] == 'Y'
                profile.email_profile.supports_notifications = email_profile_hash['CANNOTIFY'] == 'Y'
            end
            
            profile
        end
    end
    
    class BankingAccount
        def to_ofx_102_request_body
            body = []
            body << "        <BANKACCTFROM>"
            body << "          <BANKID>#{bank_identifier}"
            body << "          <BRANCHID>#{branch_identifier}" if branch_identifier
            body << "          <ACCTID>#{account_identifier}"
            body << "          <ACCTTYPE>#{BankingAccount.account_type_to_ofx_102_s(account_type)}"
            body << "          <ACCTKEY>#{account_key}" if account_key
            body << "        </BANKACCTFROM>\n"
            body.join("\n")
        end
        
        def self.ofx_102_s_to_account_type(account_type)
            case account_type
                when 'CHECKING' then :checking
                when 'SAVINGS' then :savings
                when 'MONEYMRKT' then :money_market
                when 'CREDITLINE' then :line_of_credit
                else raise NotImplementedError
            end
        end
        def self.account_type_to_ofx_102_s(account_type)
            case account_type
                when :checking then 'CHECKING'
                when :savings then 'SAVINGS'
                when :money_market then 'MONEYMRKT'
                when :line_of_credit then 'CREDITLINE'
                else raise NotImplementedError
            end
        end
        
        def self.from_ofx_102_hash(account_hash)
            account = OFX::BankingAccount.new
            
            account.bank_identifier = account_hash['BANKID']
            account.branch_identifier = account_hash['BRANCHID']
            account.account_identifier = account_hash['ACCTID']
            account.account_type = BankingAccount.ofx_102_s_to_account_type(account_hash['ACCTTYPE'])
            account.account_key = account_hash['ACCTKEY']
            
            account
        end
    end
    
    class BankingStatementRequest < TransactionalRequest
        def ofx_102_name
            'STMT'
        end
        def ofx_102_request_body
            body = ""
            
            body += account.to_ofx_102_request_body
            
            body +=
            "        <INCTRAN>\n"
            
            body +=
            "          <DTSTART>#{included_range.begin.to_ofx_102_s}\n" +
            "          <DTEND>#{included_range.end.to_ofx_102_s}\n" if included_range
            body +=
            "          <INCLUDE>#{include_transactions.to_ofx_102_s}\n" if include_transactions
            
            body +=
            "        </INCTRAN>" if include_transactions
            
            body
        end
        
        def self.from_ofx_102_hash(transaction_hash)
            raise NotImplementedError
        end
    end
    
    class BankingStatementResponse < TransactionalResponse
        def ofx_102_name
            'STMT'
        end
        
        def ofx_102_response_body
            raise NotImplementedError
        end
        
        def self.from_ofx_102_hash(transaction_hash)
            response = BankingStatementResponse.new
                       
            response.transaction_identifier = transaction_hash['TRNUID']
            response.status = OFX::Status.from_ofx_102_hash(transaction_hash['STATUS'])
            
            response_hash = transaction_hash['STMTRS']
            return unless response_hash
            
            response.default_currency = response_hash['CURDEF']
            response.account = BankingAccount.from_ofx_102_hash(response_hash['BANKACCTFROM'])
            
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
end