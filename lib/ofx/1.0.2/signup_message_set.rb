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
    class SignupMessageSet < MessageSet
        def ofx_102_message_set_name
            'SIGNUP'
        end
        
        def request_or_response_from_ofx_102_tag_name(response_or_request_name)
            case response_or_request_name
                when "ACCTINFOTRNRQ" then   AccountInformationRequest.new
                when "ACCTINFOTRNRS" then   AccountInformationResponse.new
                else                        raise NotImplementedError, response_or_request_name
            end
        end
        
        def self.from_ofx_102_hash(message_set_hash)
            message_set = SignupMessageSet.new
            
            message_set_hash.each_pair() do |transaction_name, transaction_hash|
                case transaction_name
                    when "ACCTINFOTRNRQ" then   message_set.requests << AccountInformationRequest.from_ofx_102_hash(transaction_hash)
                    when "ACCTINFOTRNRS" then   message_set.responses << AccountInformationResponse.from_ofx_102_hash(transaction_hash)
                    else                        raise NotImplementedError, transaction_name
                end
            end
            
            return message_set
        end
    end
    
    class SignupMessageSetProfile < MessageSetProfile
        def self.from_ofx_102_hash(message_set_description_hash)
            profile = OFX::SignupMessageSetProfile.new
            profile.message_set_class = OFX::SignupMessageSet
            profile.from_ofx_102_hash(message_set_description_hash)
            
            if (message_set_description_hash['CLIENTENROLL'])
                profile.enrollment = OFX::ClientEnrollment.new((message_set_description_hash['CLIENTENROLL']['ACCTREQUIRED'] == 'Y'))
            elsif (message_set_description_hash['WEBENROLL'])
                profile.enrollment = OFX::WebEnrollment.new(URI.parse(message_set_description_hash['WEBENROLL']['URL']))
            elsif (message_set_description_hash['OTHERENROLL'])
                profile.enrollment = OFX::OtherEnrollment.new(message_set_description_hash['OTHERENROLL']['MESSAGE'])
            end
            
            profile.user_information_changes_allowed = message_set_description_hash['CHGUSERINFO'] == 'Y'
            profile.available_account_requests_allowed = message_set_description_hash['AVAILACCTS'] == 'Y'
            profile.service_activation_requests_allowed = message_set_description_hash['CLIENTACTREQ'] == 'Y'
            
            profile
        end
    end
    class SignupMessageSetProfile < MessageSetProfile
        def self.message_set_class
            SignupMessageSet
        end
        
        attr_accessor :enrollment
    end
    class Enrollment
    end
    class ClientEnrollment < Enrollment
        attr_accessor :account_number_required
        def account_number_required?
            @account_number_required
        end
    end
    class WebEnrollment < Enrollment
        attr_accessor :url
    end
    class OtherEnrollment < Enrollment
        attr_accessor :message
    end
    
    class AccountInformationRequest < TransactionalRequest
        def ofx_102_name
            'ACCTINFO'
        end
        
        def ofx_102_request_body
            "      <DTACCTUP>#{date_of_last_account_update.to_ofx_102_s}"
        end
        
        def self.from_ofx_102_hash(request_hash)
            raise NotImplementedError
        end
    end
    
    class AccountInformationResponse < TransactionalResponse
        def ofx_102_name
            'ACCTINFO'
        end
        
        def ofx_102_response_body
            raise NotImplementedError
        end
        
        def self.from_ofx_102_hash(transaction_hash)
            response = AccountInformationResponse.new
                       
            response.transaction_identifier = transaction_hash['TRNUID']
            response.status = OFX::Status.from_ofx_102_hash(transaction_hash['STATUS'])
            
            response_hash = transaction_hash['ACCTINFORS']
            response.date_of_last_account_update = response_hash['DTACCTUP'].to_datetime
            
            response.accounts = []
            account_infos = response_hash['ACCTINFO'] if response_hash['ACCTINFO'].kind_of?(Array)
            account_infos = [response_hash['ACCTINFO']] if response_hash['ACCTINFO'].kind_of?(Hash)
            account_infos = [] unless account_infos
            account_infos.each do |account_info_hash|
                account_info = OFX::AccountInformation.new
                account_info.description = account_info_hash['DESC']
                account_info.phone_number = account_info_hash['PHONE']
                
                if account_info_hash['BANKACCTINFO']
                    bank_acct_info_hash = account_info_hash['BANKACCTINFO']
                    account_info.account_information = OFX::BankingAccountInformation.new
                    
                    acct_from_hash = bank_acct_info_hash['BANKACCTFROM']
                    account_info.account_information.account = OFX::BankingAccount.new
                    account_info.account_information.account.bank_identifier = acct_from_hash['BANKID']
                    account_info.account_information.account.branch_identifier = acct_from_hash['BRANCHID']
                    account_info.account_information.account.account_identifier = acct_from_hash['ACCTID']
                    account_info.account_information.account.account_type = case acct_from_hash['ACCTTYPE']
                                                                                when 'CHECKING' then :checking
                                                                                when 'SAVINGS' then :savings
                                                                                when 'MONEYMRKT' then :money_market
                                                                                when 'CREDITLINE' then :line_of_credit
                                                                                else raise NotImplementedError
                                                                            end
                    account_info.account_information.account.account_key = acct_from_hash['ACCTKEY']
                    
                    account_info.account_information.supports_transaction_detail_downloads = bank_acct_info_hash['SUPTXDL'] == 'Y'
                    account_info.account_information.transfer_source = bank_acct_info_hash['XFERSRC'] == 'Y'
                    account_info.account_information.transfer_destination = bank_acct_info_hash['XFERDEST'] == 'Y'
                    account_info.account_information.status = case bank_acct_info_hash['SVCSTATUS']
                                                                when 'AVAIL' then :available
                                                                when 'PEND' then :pending
                                                                when 'ACTIVE' then :active
                                                                else raise NotImplementedError
                                                              end
                elsif account_info_hash['CCACCTINFO']
                    cc_acct_info_hash = account_info_hash['CCACCTINFO']
                    account_info.account_information = OFX::CreditCardAccountInformation.new
                    
                    acct_from_hash = cc_acct_info_hash['CCACCTFROM']
                    account_info.account_information.account = OFX::CreditCardAccount.new
                    account_info.account_information.account.account_identifier = acct_from_hash['ACCTID']
                    account_info.account_information.account.account_key = acct_from_hash['ACCTKEY']
                    
                    account_info.account_information.supports_transaction_detail_downloads = cc_acct_info_hash['SUPTXDL'] == 'Y'
                    account_info.account_information.transfer_source = cc_acct_info_hash['XFERSRC'] == 'Y'
                    account_info.account_information.transfer_destination = cc_acct_info_hash['XFERDEST'] == 'Y'
                    account_info.account_information.status = case cc_acct_info_hash['SVCSTATUS']
                                                                when 'AVAIL' then :available
                                                                when 'PEND' then :pending
                                                                when 'ACTIVE' then :active
                                                                else raise NotImplementedError
                                                              end
                else
                    raise NotImplementedError
                end
                
                response.accounts << account_info
            end
            
            response
        end
    end
end