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

require 'uri'

module OFX
    class FinancialInstitutionProfileMessageSet < MessageSet
        def ofx_102_message_set_name
            'PROF'
        end
        
        def self.from_ofx_102_hash(message_set_hash)
            message_set = FinancialInstitutionProfileMessageSet.new
            
            message_set_hash.each_pair() do |transaction_name, transaction_hash|
                case transaction_name
                    when "PROFTRNRQ" then   message_set.requests << FinancialInstitutionProfileRequest.from_ofx_102_hash(transaction_hash)
                    when "PROFTRNRS" then   message_set.responses << FinancialInstitutionProfileResponse.from_ofx_102_hash(transaction_hash)
                    else                    raise NotImplementedError, transaction_name
                end
            end
            
            return message_set
        end
    end
    
    class FinancialInstitutionProfileMessageSetProfile < MessageSetProfile
        def self.from_ofx_102_hash(message_set_description_hash)
            profile = OFX::FinancialInstitutionProfileMessageSetProfile.new
            profile.message_set_class = OFX::FinancialInstitutionProfileMessageSet
            profile.from_ofx_102_hash(message_set_description_hash)
        
            profile
        end
    end

    class FinancialInstitutionProfileRequest < TransactionalRequest
        def ofx_102_name
            'PROF'
        end
        def ofx_102_request_body
            "        <CLIENTROUTING>#{client_routing}\n" +
            "        <DTPROFUP>#{date_of_last_profile_update.to_ofx_102_s}"
        end
        
        def self.from_ofx_102_hash(transaction_hash)
            raise NotImplementedError
        end
    end
    
    class FinancialInstitutionProfileResponse < TransactionalResponse
        def ofx_102_name
            'PROF'
        end
        
        def ofx_102_response_body
            raise NotImplementedError
        end
        
        def self.from_ofx_102_hash(transaction_hash)
            response = FinancialInstitutionProfileResponse.new
                       
            response.transaction_identifier = transaction_hash['TRNUID']
            response.status = OFX::Status.from_ofx_102_hash(transaction_hash['STATUS'])
            
            response.message_sets = {}
            response.signon_realms = []
            
            response_hash = transaction_hash['PROFRS']
            if response_hash
                response.date_of_last_profile_update = response_hash['DTPROFUP'].to_datetime
                response.financial_institution_name = response_hash['FINAME']
                response.address = response_hash['ADDR1'] || ""
                response.address += "\n" + response_hash['ADDR2'] if response_hash['ADDR2']
                response.address += "\n" + response_hash['ADDR3'] if response_hash['ADDR3']
                response.city = response_hash['CITY']
                response.state = response_hash['STATE']
                response.postal_code = response_hash['POSTALCODE']
                response.country = response_hash['COUNTRY']
                response.customer_service_telephone = response_hash['CSPHONE']
                response.technical_support_telephone = response_hash['TSPHONE']
                response.facsimile_telephone = response_hash['FAXPHONE']
                response.url = URI.parse(response_hash['URL']) if response_hash['URL']
                response.email_address = response_hash['EMAIL']
                
                message_sets_hash = response_hash['MSGSETLIST']
                #require 'pp'
                #pp message_sets_hash
                message_sets_hash.each_pair do |message_set_name, message_set_descriptions|
                    profile_class = MESSAGE_SET_NAMES_TO_PROFILE_CLASSES[message_set_name]                    
                    supported_messages = response.message_sets[profile_class.message_set_class] = {}
                    message_set_descriptions.each do |message_set_version_name, message_set_description|
                        supported_messages[OFX::Version.new(message_set_version_name[-1..-1].to_i)] = 
                            profile_class.from_ofx_102_hash(message_set_description)
                    end
                end
                
                signons_hash = response_hash['SIGNONINFOLIST']
                #require 'pp'
                #pp signons_hash
                signons_hash.each_pair do |aggregate_name, signon_realm_info|
                    signon_realm = SignonRealm.new
                    
                    signon_realm.name = signon_realm_info['SIGNONREALM']
                    signon_realm.password_length_constraint = signon_realm_info['MIN'].to_i..signon_realm_info['MAX'].to_i
                    signon_realm.password_characters_constraint = case signon_realm_info['CHARTYPE']
                                                                    when 'ALPHAONLY' then :alphabetic_only
                                                                    when 'NUMERICONLY' then :numeric_only
                                                                    when 'ALPHAORNUMERIC' then :alphabetic_or_numeric
                                                                    when 'ALPHAANDNUMERIC' then :alphabetic_and_numeric
                                                                  end
                    signon_realm.case_sensitive = signon_realm_info['CASESEN'] == 'Y'
                    signon_realm.allows_special_characters = signon_realm_info['SPECIAL'] == 'Y'
                    signon_realm.allows_spaces = signon_realm_info['SPACES'] == 'Y'
                    signon_realm.supports_pin_changes = signon_realm_info['PINCH'] == 'Y'
                    signon_realm.requires_initial_pin_change = signon_realm_info['CHGPINFIRST'] == 'Y'
        
                    response.signon_realms << signon_realm
                end
            end
            
            return response
        end
        
        private
        MESSAGE_SET_NAMES_TO_PROFILE_CLASSES =
        {
            'SIGNONMSGSET'          => OFX::SignonMessageSetProfile,
            'SIGNUPMSGSET'          => OFX::SignupMessageSetProfile,
            'BANKMSGSET'            => OFX::BankingMessageSetProfile,
            'CREDITCARDMSGSET'      => OFX::CreditCardStatementMessageSetProfile,
            'INVSTMTMSGSET'         => OFX::InvestmentStatementMessageSetProfile,
            'INTERXFERMSGSET'       => OFX::InterbankFundsTransferMessageSetProfile,
            'WIREXFERMSGSET'        => OFX::WireFundsTransferMessageSetProfile,
            'BILLPAYMSGSET'         => OFX::PaymentMessageSetProfile,
            'EMAILMSGSET'           => OFX::EmailMessageSetProfile,
            'SECLISTMSGSET'         => OFX::InvestmentSecurityListMessageSetProfile,
            'PROFMSGSET'            => OFX::FinancialInstitutionProfileMessageSetProfile
        }
    end
end