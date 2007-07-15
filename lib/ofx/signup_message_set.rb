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
    class SignupMessageSet < MessageSet
        def precedence
            2
        end
        def version
            1
        end
    end
    
    class SignupMessageSetProfile < MessageSetProfile
        def self.message_set_class
            SignupMessageSet
        end
        
        attr_accessor :enrollment
        attr_accessor :user_information_changes_allowed
        def user_information_changes_allowed?
            user_information_changes_allowed
        end
        attr_accessor :available_account_requests_allowed
        def available_account_requests_allowed?
            available_account_requests_allowed
        end
        attr_accessor :service_activation_requests_allowed
        def service_activation_requests_allowed?
            service_activation_requests_allowed
        end
    end
    class Enrollment
    end
    class ClientEnrollment < Enrollment
        attr_accessor :account_number_required
        def account_number_required?
            @account_number_required
        end
        def initialize(account_number_required)
            @account_number_required = account_number_required
        end
    end
    class WebEnrollment < Enrollment
        attr_accessor :url
        def initialize(url)
            @url = url
        end
    end
    class OtherEnrollment < Enrollment
        attr_accessor :message
        def initialize(message)
            @message = message
        end
    end
    
    class AccountInformationRequest < TransactionalRequest
        attr_accessor :date_of_last_account_update
    end
    class AccountInformationResponse < TransactionalResponse
        attr_accessor :date_of_last_account_update
        attr_accessor :accounts
    end
    
    class AccountInformation
        attr_accessor :description
        attr_accessor :phone_number
        attr_accessor :account_information
    end
end