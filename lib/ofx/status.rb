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
    class Status
        attr_accessor :code
        attr_accessor :severity
        attr_accessor :message
        
        def initialize(code, severity, message)
            @code = code
            @severity = severity
            @message = message
        end
        
        def self.from_numerical_code_severity_and_message(code, severity, message)
            status_class = CODES_TO_OFX_STATUS[code] || SEVERITIES_TO_UNKNOWN_OFX_STATUS[severity]
            raise unless status_class
            
            status_class.new(code, severity, message)
        end
    end

    class Information < Status
    end
    class Warning < Status
    end
    class Error < Status
    end
    
    class UnknownInformation < Information
    end
    class UnknownWarning < Warning
    end
    class UnknownError < Error
    end
    
    # general statuses
    class Success < Information
    end
    class GeneralError < Error
    end
    class UnsupportedVersion < Error
    end
    
    # signon message set
    class MustChangePassword < Information
    end
    class SignonInvalid < Error
    end
    class CustomerAccountAlreadyInUse < Error
    end
    class AccountLockedOut < Error
    end
    
    # financial institution profile message set
    class ClientUpToDate < Information
    end
    
    # build tables of the status subclasses
    class Status
        private
        SEVERITIES_TO_UNKNOWN_OFX_STATUS =
        {
            :information    => UnknownInformation,
            :warning        => UnknownWarning,
            :error          => UnknownError
        }
        CODES_TO_OFX_STATUS =
        {
            # general codes
            0       => Success,
            2000    => GeneralError,
            2021    => UnsupportedVersion,
            
            # signon message set
            15000   => MustChangePassword,
            15500   => SignonInvalid,
            15501   => CustomerAccountAlreadyInUse,
            15502   => AccountLockedOut,
            
            # financial institution profile message set
            1       => ClientUpToDate
        }
    end
end