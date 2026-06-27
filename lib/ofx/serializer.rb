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
require File.dirname(__FILE__) + '/2.0.0/serializer'

module OFX
    class Serializer
        def self.get(version)
            version = OFX::Version.new(version)

            if version == OFX::Version.new("1.0.2") || version == OFX::Version.new("1.0.3")
                return OFX::OFX102::Serializer.new
            elsif version.major == 2
                return OFX::OFX200::Serializer.new
            else
                raise NotImplementedError
            end
        end

        def self.from_http_response_body(body)
            body = body.to_s.lstrip

            if OFX::OFX200::Serializer.xml_ofx?(body)
                OFX::OFX200::Serializer.new.from_http_response_body(body)
            else
                OFX::OFX102::Serializer.new.from_http_response_body(body)
            end
        end

        def to_http_post_body(document)
            raise NotImplementedError
        end

        def from_http_request_body(document)
            raise NotImplementedError
        end

        def from_http_response_body(body)
            self.class.from_http_response_body(body)
        end
    end
end
