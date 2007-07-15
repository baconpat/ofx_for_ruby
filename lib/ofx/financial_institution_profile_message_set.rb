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
    class FinancialInstitutionProfileMessageSet < MessageSet
        def precedence
            11
        end
        def version
            1
        end
    end
    
    class FinancialInstitutionProfileMessageSetProfile < MessageSetProfile
        def self.message_set_class
            FinancialInstitutionProfileMessageSet
        end
    end
    
    class SignonRealm
        attr_accessor :name
        attr_accessor :password_length_constraint
        attr_accessor :password_characters_constraint
        attr_accessor :case_sensitive
        attr_accessor :allows_special_characters
        attr_accessor :allows_spaces
        attr_accessor :supports_pin_changes
        attr_accessor :requires_initial_pin_change
    end

    class FinancialInstitutionProfileRequest < TransactionalRequest
        attr_accessor :client_routing
        attr_accessor :date_of_last_profile_update
    end
    
    class FinancialInstitutionProfileResponse < TransactionalResponse
        attr_accessor :message_sets
        attr_accessor :signon_realms

        attr_accessor :date_of_last_profile_update
        attr_accessor :financial_institution_name
        attr_accessor :address
        attr_accessor :city
        attr_accessor :state
        attr_accessor :postal_code
        attr_accessor :country
        attr_accessor :customer_service_telephone
        attr_accessor :technical_support_telephone
        attr_accessor :facsimile_telephone
        attr_accessor :url
        attr_accessor :email_address
    end
end