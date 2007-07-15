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
    class EmailMessageSet < MessageSet
        def precedence
            9
        end
        def version
            1
        end
    end
    
    class EmailMessageSetProfile < MessageSetProfile
        def self.message_set_class
            EmailMessageSet
        end
        
        attr_accessor :supports_email
        def supports_email?
            supports_email
        end
        attr_accessor :supports_mime_messages
        def supports_mime_messages?
            supports_mime_messages
        end
    end
end