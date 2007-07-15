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
    class Header
        def to_ofx_102_s
            headers = ""

            headers += "OFXHEADER:" + self.header_version.to_compact_s + "\n"
            headers += "DATA:" + self.content_type.to_s + "\n"
            headers += "VERSION:" + self.document_version.to_compact_s + "\n"
            headers += "SECURITY:" + self.security.to_s + "\n"
            headers += "ENCODING:" + self.content_encoding.to_s + "\n"
            headers += "CHARSET:" + self.content_character_set.to_s + "\n"
            headers += "COMPRESSION:" + self.compression.to_s + "\n"
            headers += "OLDFILEUID:" + self.previous_unique_identifier.to_s + "\n"
            headers += "NEWFILEUID:" + self.unique_identifier.to_s + "\n"

            headers
        end
        
        def self.from_ofx_102_s(header_string)
            header = OFX::Header.new
        
            header_pattern = /^(\w+)\:(.*)$/
            header_string.split("\n").each do |this_header|
                header_match = header_pattern.match(this_header)
                header[header_match[1]] = header_match[2]
           end
            
            header
        end
    end
end