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

require File.dirname(__FILE__) + '/capital_one_helper'

class CapitalOneOFXHTTPClientTest < Test::Unit::TestCase

    include CapitalOneHelper
    
    def setup
        setup_capital_one_credentials
    end

    def test_account_info_request_to_capital_one
        account_info_request =
"OFXHEADER:100
DATA:OFXSGML
VERSION:102
SECURITY:NONE
ENCODING:USASCII
CHARSET:1252
COMPRESSION:NONE
OLDFILEUID:NONE
NEWFILEUID:20070518034113.000

<OFX>
<SIGNONMSGSRQV1>
<SONRQ>
<DTCLIENT>20070518034113.000
<USERID>#{@user_name}
<USERPASS>#{@password}
<LANGUAGE>ENG
<FI>
<ORG>Hibernia
<FID>1001
</FI>
<APPID>QWIN
<APPVER>1200
</SONRQ>
</SIGNONMSGSRQV1>
<SIGNUPMSGSRQV1>
<ACCTINFOTRNRQ>
<TRNUID>#{DateTime.now.to_ofx_102_s}
<CLTCOOKIE>1
<ACCTINFORQ>
<DTACCTUP>19700101
</ACCTINFORQ>
</ACCTINFOTRNRQ>
</SIGNUPMSGSRQV1>
</OFX>"

        client = OFX::HTTPClient.new(URI.parse('https://onlinebanking.capitalone.com/scripts/serverext.dll'))
        account_info_response = client.send(account_info_request)
        assert account_info_response != nil
        assert account_info_response[0..12] == 'OFXHEADER:100'
    end

end