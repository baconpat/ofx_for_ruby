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

require File.dirname(__FILE__) + '/citi_helper'

class CitiOFXHTTPClientTest < Test::Unit::TestCase

    include CitiHelper
    
    def setup
        setup_citi_credentials
    end

    def test_account_info_request_to_citi
        account_info_request =
"OFXHEADER:100
DATA:OFXSGML
VERSION:102
SECURITY:NONE
ENCODING:USASCII
CHARSET:1252
COMPRESSION:NONE
OLDFILEUID:NONE
NEWFILEUID:20070624162951.735621

<OFX>
  <SIGNONMSGSRQV1>
    <SONRQ>
      <DTCLIENT>20070624162951.736219[0:Z]
      <USERID>#{@user_name}
      <USERPASS>#{@password}
      <LANGUAGE>ENG
      <FI>
        <ORG>Citigroup
        <FID>24909
      </FI>
      <APPID>OFX
      <APPVER>0010
    </SONRQ>
  </SIGNONMSGSRQV1>
  <PROFMSGSRQV1>
    <PROFTRNRQ>
      <TRNUID>20070624162951.737132
      <PROFRQ>
        <CLIENTROUTING>MSGSET
        <DTPROFUP>20010101000000.0[0:Z]
      </PROFRQ>
    </PROFTRNRQ>
  </PROFMSGSRQV1>
</OFX>"

        client = OFX::HTTPClient.new(URI.parse('https://secureofx2.bankhost.com/citi/cgi-forte/ofx_rt?servicename=ofx_rt&pagename=ofx'))
        account_info_response = client.send(account_info_request)
        assert account_info_response != nil
        assert account_info_response[0..12] == 'OFXHEADER:100'
    end
end