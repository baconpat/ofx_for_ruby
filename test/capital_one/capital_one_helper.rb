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

require File.dirname(__FILE__) + '/../test_helper'

require 'uri'

module CapitalOneHelper

    def setup_capital_one_credentials()
        File.open(File.dirname(__FILE__) + '/fixtures/capital-one-credentials') do |file|
            @user_name, @password = file.gets.split(',')
        end
    end
    
    def setup_capital_one_accounts()
        File.open(File.dirname(__FILE__) + '/fixtures/capital-one-accounts') do |file|
            @accounts = {}
            file.each_line do |line|
                type, account = line.split(',')
                @accounts[type.chomp.to_sym] = account.chomp
            end
        end
    end

    def verify_capital_one_header(response_document)
        assert_not_equal(nil, response_document.header)
        assert_equal(OFX::Version.new("1.0.0"), response_document.header.header_version)
        assert_equal('OFXSGML', response_document.header.content_type)
        assert_equal(OFX::Version.new("1.0.2"), response_document.header.document_version)
        assert_equal('NONE', response_document.header.security)
        assert_equal('USASCII', response_document.header.content_encoding)
        assert_equal('1252', response_document.header.content_character_set)
        assert_equal('NONE', response_document.header.compression)
        assert_not_equal(nil, response_document.header.unique_identifier)
        assert_not_equal(nil, response_document.header.previous_unique_identifier)
    end
    
    def verify_capital_one_signon_response(response_document)
        signon_message = response_document.message_sets[0]
        assert signon_message.kind_of?(OFX::SignonMessageSet)
        assert_equal(1, signon_message.responses.length)
        
        signon_response = signon_message.responses[0]
        assert signon_response.kind_of?(OFX::SignonResponse)
        assert_not_equal(nil, signon_response.status)
        assert signon_response.status.kind_of?(OFX::Information)
        assert signon_response.status.kind_of?(OFX::Success)
        assert_equal(0, signon_response.status.code)
        assert_equal(:information, signon_response.status.severity)
        assert_not_equal(nil, signon_response.status.message)
        assert_not_equal(nil, signon_response.date)
        assert_equal(nil, signon_response.user_key)
        assert_equal('ENG', signon_response.language)
        assert_not_equal(nil, signon_response.date_of_last_profile_update)
        assert_not_equal(nil, signon_response.date_of_last_account_update)
        assert_not_equal(nil, signon_response.financial_institution_identification)
        assert_equal('Hibernia', signon_response.financial_institution_identification.organization)
        assert_equal('1001', signon_response.financial_institution_identification.financial_institution_identifier)
        assert_equal(nil, signon_response.session_cookie)
    end
    
end