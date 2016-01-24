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
    class FinancialInstitution

        def self.get_institution(financial_institution_name, ofx_client_id=nil, ssl_version=nil)
            case financial_institution_name
                when 'Capital One'
                    FinancialInstitution.new('Capital One',
                                             URI.parse('https://onlinebanking.capitalone.com/ofx/process.ofx'),
                                             OFX::Version.new("1.0.2"),
                                             'Hibernia', '1001', '065002030',
                                             ofx_client_id, ssl_version)
                when 'Citi'
                    FinancialInstitution.new('Citi',
                                             URI.parse('https://www.accountonline.com/cards/svc/CitiOfxManager.do'),
                                             OFX::Version.new("1.0.2"),
                                             'Citigroup', '24909', nil,
                                             'Quicken', ssl_version)
                when 'Chase'
                    FinancialInstitution.new('Chase',
                                             URI.parse('https://ofx.chase.com'),
                                             OFX::Version.new("1.0.3"),
                                             'B1', '10898', nil,
                                             'Quicken', :TLSv1)
                when 'AMEX'
                    FinancialInstitution.new('AMEX',
                                             URI.parse('https://online.americanexpress.com/myca/ofxdl/desktop/desktopDownload.do?request_type=nl_ofxdownload'),
                                             OFX::Version.new("1.0.2"),
                                             'AMEX', '3101', nil,
                                             'Quicken', ssl_version)
                when 'Schwab'
                     FinancialInstitution.new('Schwab',
                                             URI.parse('https://ofx.schwab.com/bankcgi_dev/ofx_server'),
                                             OFX::Version.new("1.0.2"),
                                             'ISC', '101', '121202211',
                                             'Quicken', ssl_version) 
                when 'Fidelity'
                     FinancialInstitution.new('Fidelity',
                                             URI.parse('https://ofx.fidelity.com/ftgw/OFX/clients/download'),
                                             OFX::Version.new("1.0.2"),
                                             'fidelity.com', '7776', nil,
                                             'Quicken', ssl_version) 
                else
                    raise NotImplementedError
            end
        end

        attr :name
        attr :ofx_uri
        attr :ofx_version
        attr :organization_name
        attr :organization_id
        attr :bank_identifier
        attr :client

        def initialize(name, ofx_uri, ofx_version, org_name, org_id, bank_id=nil, client_id=nil, ssl_version=nil)
            @name = name
            @ofx_uri = ofx_uri
            @ofx_version = ofx_version
            @organization_name = org_name
            @organization_id = org_id
            @bank_identifier = bank_id
            @client = nil
            @ofx_client_id = client_id
            @ofx_ssl_version = ssl_version
        end

        def set_client(user_name, password)
          inst_id = OFX::FinancialInstitutionIdentification.new(
                            @organization_name, @organization_id)
          user_cred = OFX::UserCredentials.new(user_name, password)
          @client = OFX::FinancialClient.new([[inst_id, user_cred]])
        end

        # anonymous can be used for ProfileRequest
        def set_client_anon
          user_name = "anonymous00000000000000000000000"
          password = "anonymous00000000000000000000000"
          set_client(user_name, password)
        end

        def create_request_document()
            document = OFX::Document.new

            case ofx_version
                when OFX::Version.new("1.0.2")
                    document.header.header_version = OFX::Version.new("1.0.0")
                    document.header.content_type = "OFXSGML"
                    document.header.document_version = OFX::Version.new("1.0.2")
                when OFX::Version.new("1.0.3")
                     document.header.header_version = OFX::Version.new("1.0.0")
                     document.header.content_type = "OFXSGML"
                     document.header.document_version = OFX::Version.new("1.0.3")
                else
                    raise NotImplementedError
            end

            document.header.security = "NONE"
            document.header.content_encoding = "USASCII"
            document.header.content_character_set = "1252"
            document.header.compression = "NONE"
            document.header.previous_unique_identifier = "NONE"
            document.header.unique_identifier = OFX::FileUniqueIdentifier.new

            document
        end

        def create_request_document_signon
          return nil if @client.nil?
          requestDocument = self.create_request_document
          requestDocument.message_sets << @client.create_signon_request_message(@organization_id, @ofx_client_id)
          return requestDocument
	end

        def create_request_document_profile_update(request_date=nil)
          return nil if @client.nil?
          if request_date.nil?
            request_date = DateTime.new(2001, 1, 1)
          end
          profileMessageSet = OFX::FinancialInstitutionProfileMessageSet.new
          profileRequest = OFX::FinancialInstitutionProfileRequest.new
          profileRequest.transaction_identifier = OFX::TransactionUniqueIdentifier.new
          profileRequest.client_routing = 'MSGSET'
          profileRequest.date_of_last_profile_update = request_date
          profileMessageSet.requests << profileRequest

          requestDocument = self.create_request_document
          requestDocument.message_sets << @client.create_signon_request_message(@organization_id, @ofx_client_id)
          requestDocument.message_sets << profileMessageSet
          return requestDocument
	end

        def create_request_document_signup(request_date=nil)
          return nil if @client.nil?
          if request_date.nil?
            request_date = DateTime.new(2001, 1, 1)
          end
          signup_message_set = OFX::SignupMessageSet.new
          account_info_request = OFX::AccountInformationRequest.new
          account_info_request.transaction_identifier = OFX::TransactionUniqueIdentifier.new
          account_info_request.date_of_last_account_update = request_date
          signup_message_set.requests << account_info_request

          requestDocument = self.create_request_document
          requestDocument.message_sets << @client.create_signon_request_message(@organization_id, @ofx_client_id)
          requestDocument.message_sets << signup_message_set
          return requestDocument
        end

        def create_request_document_for_cc_statement(account_id, date_range=nil, include_trans=true)
          return nil if @client.nil?
          cc_message_set = OFX::CreditCardStatementMessageSet.new
          statement_request = OFX::CreditCardStatementRequest.new
          statement_request.transaction_identifier = OFX::TransactionUniqueIdentifier.new
          statement_request.account = OFX::CreditCardAccount.new
          statement_request.account.account_identifier = account_id
          if include_trans
            statement_request.included_range = date_range
            statement_request.include_transactions = include_trans
          end
          cc_message_set.requests << statement_request

          requestDocument = self.create_request_document
          requestDocument.message_sets << @client.create_signon_request_message(@organization_id, @ofx_client_id)
          requestDocument.message_sets << cc_message_set
          return requestDocument
	end

        def create_request_document_for_cc_closing_statement(account_id)
          create_request_document_for_cc_statement(account_id, nil, false)
        end

        def create_request_document_for_bank_statement(account_id, date_range=nil, account_type = :checking)
          return nil if @client.nil?
          banking_message_set = OFX::BankingMessageSet.new
          statement_request = OFX::BankingStatementRequest.new
          statement_request.transaction_identifier = OFX::TransactionUniqueIdentifier.new
          statement_request.account = OFX::BankingAccount.new
          statement_request.account.bank_identifier = @bank_identifier
          statement_request.account.branch_identifier = nil
          statement_request.account.account_identifier = account_id
          statement_request.account.account_type = account_type
          statement_request.account.account_key = nil
          statement_request.include_transactions = true
          statement_request.included_range = date_range  # example DateRange (start.to_date)..(end.to_date)
          banking_message_set.requests << statement_request

          requestDocument = self.create_request_document
          requestDocument.message_sets << @client.create_signon_request_message(@organization_id, @ofx_client_id)
          requestDocument.message_sets << banking_message_set
          return requestDocument
        end

        def get_account_id
            req = create_request_document_signup
            return nil if req.nil?
            resp = send(req)
            id = resp.message_sets[1].responses[0].account_identifier if resp
            return id
        end

        def send(document)
            serializer = OFX::Serializer.get(@ofx_version)
            request_body = serializer.to_http_post_body(document)

            client = OFX::HTTPClient.new(@ofx_uri)
            response_body = client.send(request_body, @ofx_ssl_version)

            return serializer.from_http_response_body(response_body)
        end

##
## Debugging routines
##
        def get_anon_profile
            set_client_anon
            return send(create_request_document_profile_update)
        end

        def document_to_post_data(document, no_whitespace=false)
            serializer = OFX::Serializer.get(@ofx_version)
            request_body = serializer.to_http_post_body(document)
            if no_whitespace
                request_body.delete! " "
            end
            return request_body
        end

        def send_from_post_data(data, debug_req=false, debug_resp=false)
            client = OFX::HTTPClient.new(@ofx_uri)
            request_body = data
            response_body = client.send(request_body, @ofx_ssl_version, debug_req, debug_resp)

            serializer = OFX::Serializer.get(@ofx_version)
            return serializer.from_http_response_body(response_body)
        end
    end
end
