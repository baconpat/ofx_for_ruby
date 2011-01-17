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
    class Version
        include Comparable

        def initialize(version)
            @version = [0, 0, 0]
            
            return if version.nil?
            
            parts = case version
            when Version
              version.to_a
            when Integer
              [version, 0, 0]
            when Array
              version
            when /\./
              version.split(".")
            else
              [version[0..0], version[1..1], version[2..2]]
            end

            @version[0] = parts[0].to_i
            @version[1] = parts[1].to_i
            @version[2] = parts[2].to_i
        end

        def major
            @version[0]
        end

        def minor
            @version[1]
        end

        def revision
            @version[2]
        end

        def to_dotted_s
            @version.join('.')
        end
        def to_compact_s
            @version.join('')
        end

        def to_a
            @version.dup
        end

        def empty?
            @version == [0, 0, 0]
        end

        def <=> (other)
            @version <=> other.to_a
        end
        def eql?(other)
            other_a = other.to_a
            
            return @version[0] == other_a[0] && @version[1] == other_a[1] && @version[2] == other_a[2]
        end
        def hash()
            return @version.hash
        end
    end
    
    VERSION = Version.new('0.1.2')
end