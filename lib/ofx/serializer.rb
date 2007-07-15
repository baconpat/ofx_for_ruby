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

require File.dirname(__FILE__) + '/1.0.2/serializer'

module OFX
    class Serializer
        def self.get(version)
            case version
                when OFX::Version.new("1.0.2")
                    return OFX::OFX102::Serializer.new
                else
                    raise NotImplementedError
            end
        end

        def to_http_post_body(document)
            raise NotImplementedError
        end

        def from_http_request_body(document)
            raise NotImplementedError
        end
    end
end