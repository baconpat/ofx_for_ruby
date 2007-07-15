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
    class Document
        def self.from_ofx_102_hash(document_hash)
            contents = document_hash['OFX']
            raise 'The top of the document was not an <OFX> tag.' unless contents
            
            document = OFX::Document.new
            
            contents.each_pair() do |message_set, message_set_hash|
                document.message_sets << OFX::MessageSet.from_ofx_102_message_set_hash(message_set, message_set_hash)
            end
            document.message_sets.sort! { |left, right| left.precedence <=> right.precedence }
            
            return document
        end
    end
end