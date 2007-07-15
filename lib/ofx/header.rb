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

    # = Summary
    # The OFX headers for one message.  The headers provide metadata about
    # the OFX request/response, including message versioning, security, and
    # encoding.
    #
    # = Specifications
    # OFX 1.0.2:: 2.2 (pp. 12-14)
    class Header

        def initialize
            @headers = {}
        end

        def [](key)
            @headers[key]
        end

        def []=(key, value)
            @headers[key] = value
        end

        # The version of this OFX header
        # OFX 1.0.2:: 2.2.1
        # OFX 1.0.3:: 2.2.1
        def header_version
            OFX::Version.new(@headers['OFXHEADER'])
        end
        def header_version=(value)
            @headers['OFXHEADER'] = value
        end

        # OFX 1.0.2:: 2.2.2
        def content_type
            @headers['DATA']
        end
        def content_type=(value)
            @headers['DATA'] = value
        end

        # OFX 1.0.2:: 2.2.3
        def document_version
            OFX::Version.new(@headers['VERSION'])
        end
        def document_version=(value)
            @headers['VERSION'] = value
        end

        # OFX 1.0.2:: 2.2.4
        def security
            @headers['SECURITY']
        end
        def security=(value)
            @headers['SECURITY'] = value
        end

        # OFX 1.0.2:: 2.2.5
        def content_encoding
            @headers['ENCODING']
        end
        def content_encoding=(value)
            @headers['ENCODING'] = value
        end

        # OFX 1.0.2:: 2.2.5
        def content_character_set
            @headers['CHARSET']
        end
        def content_character_set=(value)
            @headers['CHARSET'] = value
        end

        # OFX 1.0.2:: 2.2.6
        def compression
            @headers['COMPRESSION']
        end
        def compression=(value)
            @headers['COMPRESSION'] = value
        end

        # OFX 1.0.2:: 2.2.7
        def unique_identifier
            @headers['NEWFILEUID']
        end
        def unique_identifier=(value)
            @headers['NEWFILEUID'] = value
        end

        # OFX 1.0.2:: 2.2.7
        def previous_unique_identifier
            @headers['OLDFILEUID']
        end
        def previous_unique_identifier=(value)
            @headers['OLDFILEUID'] = value
        end
    end
end