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

        def self.get_institution(financial_institution_name)
            case financial_institution_name
                when 'Capital One'
                    FinancialInstitution.new('Capital One',
                                             URI.parse('https://onlinebanking.capitalone.com/scripts/serverext.dll'),
                                             OFX::Version.new("1.0.2"))
                when 'Citi'
                    FinancialInstitution.new('Citi',
                                             URI.parse('https://secureofx2.bankhost.com/citi/cgi-forte/ofx_rt?servicename=ofx_rt&pagename=ofx'),
                                             OFX::Version.new("1.0.2"))
                else
                    raise NotImplementedError
            end
        end

        attr :name
        attr :ofx_uri
        attr :ofx_version

        def initialize(name, ofx_uri, ofx_version)
            @name = name
            @ofx_uri = ofx_uri
            @ofx_version = ofx_version
        end

        def create_request_document()
            document = OFX::Document.new

            case ofx_version
                when OFX::Version.new("1.0.2")
                    document.header.header_version = OFX::Version.new("1.0.0")
                    document.header.content_type = "OFXSGML"
                    document.header.document_version = OFX::Version.new("1.0.2")
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

        def send(document)
            serializer = OFX::Serializer.get(@ofx_version)
            request_body = serializer.to_http_post_body(document)

            client = OFX::HTTPClient.new(@ofx_uri)
            response_body = client.send(request_body)

            return serializer.from_http_response_body(response_body)
        end
    end
end