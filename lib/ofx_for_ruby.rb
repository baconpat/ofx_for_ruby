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

require 'active_support'
require 'uri'
require 'cgi'

require 'bigdecimal'
require 'bigdecimal/util'

require 'ofx/version'
require 'ofx/status'
require 'ofx/file_unique_identifier'
require 'ofx/transaction_unique_identifier'
require 'ofx/header'
require 'ofx/message_set'
require 'ofx/document'
require 'ofx/statements'
         
require 'ofx/financial_institution'
require 'ofx/financial_client'
         
require 'ofx/signon_message_set'
require 'ofx/signup_message_set'
require 'ofx/banking_message_set'
require 'ofx/credit_card_statement_message_set'
require 'ofx/investment_statement_message_set'
require 'ofx/interbank_funds_transfer_message_set'
require 'ofx/wire_funds_transfer_message_set'
require 'ofx/payment_message_set'
require 'ofx/email_message_set'
require 'ofx/investment_security_list_message_set'
require 'ofx/financial_institution_profile_message_set'
         
require 'ofx/serializer'
         
require 'ofx/http/ofx_http_client.rb'

# = Summary
# An implementation of the OFX specification for financial systems
# integration.
#
# = Specifications
# OFX 1.0.2:: http://www.ofx.net/ofx/downloads/ofx102spec.zip
module OFX
end