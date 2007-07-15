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

require 'rubygems'
gem 'activesupport'
require 'active_support'
require 'uri'
require 'cgi'

require 'bigdecimal'
require 'bigdecimal/util'

require File.dirname(__FILE__) + '/ofx/version'
require File.dirname(__FILE__) + '/ofx/status'
require File.dirname(__FILE__) + '/ofx/file_unique_identifier'
require File.dirname(__FILE__) + '/ofx/transaction_unique_identifier'
require File.dirname(__FILE__) + '/ofx/header'
require File.dirname(__FILE__) + '/ofx/message_set'
require File.dirname(__FILE__) + '/ofx/document'
require File.dirname(__FILE__) + '/ofx/statements'

require File.dirname(__FILE__) + '/ofx/financial_institution'
require File.dirname(__FILE__) + '/ofx/financial_client'

require File.dirname(__FILE__) + '/ofx/signon_message_set'
require File.dirname(__FILE__) + '/ofx/signup_message_set'
require File.dirname(__FILE__) + '/ofx/banking_message_set'
require File.dirname(__FILE__) + '/ofx/credit_card_statement_message_set'
require File.dirname(__FILE__) + '/ofx/investment_statement_message_set'
require File.dirname(__FILE__) + '/ofx/interbank_funds_transfer_message_set'
require File.dirname(__FILE__) + '/ofx/wire_funds_transfer_message_set'
require File.dirname(__FILE__) + '/ofx/payment_message_set'
require File.dirname(__FILE__) + '/ofx/email_message_set'
require File.dirname(__FILE__) + '/ofx/investment_security_list_message_set'
require File.dirname(__FILE__) + '/ofx/financial_institution_profile_message_set'

require File.dirname(__FILE__) + '/ofx/serializer'

require File.dirname(__FILE__) + '/ofx/http/ofx_http_client.rb'

# = Summary
# An implementation of the OFX specification for financial systems
# integration.
#
# = Specifications
# OFX 1.0.2:: http://www.ofx.net/ofx/downloads/ofx102spec.zip
module OFX
end