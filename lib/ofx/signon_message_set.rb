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
    class SignonMessageSet < MessageSet
        def precedence
            1
        end
        def version
            1
        end
    end
    
    class SignonMessageSetProfile < MessageSetProfile
        def self.message_set_class
            SignonMessageSet
        end
    end

    class UserCredentials
        attr_accessor :user_identification
        attr_accessor :password

        def initialize(user_identification, password)
            @user_identification = user_identification
            @password = password
        end

    end
    class UserKey
        def user_key
            raise NotImplementedError
        end

        def expiration_date
            raise NotImplementedError
        end
    end

    class FinancialInstitutionIdentification
        attr_accessor :organization
        attr_accessor :financial_institution_identifier

        def initialize(organization, financial_institution_identifier)
            @organization = organization
            @financial_institution_identifier = financial_institution_identifier
        end
    end

    class ApplicationIdentification
        attr_accessor :application_identification
        attr_accessor :application_version

        def initialize(application_identification, application_version)
            @application_identification = application_identification
            @application_version = application_version
        end
    end

    class SignonRequest < Request
        attr_accessor :date
        attr_accessor :user_identification
        attr_accessor :generate_user_key
        attr_accessor :language
        attr_accessor :financial_institution_identification
        attr_accessor :session_cookie
        attr_accessor :application_identification

        def satisfies_requirements?
            raise NotImplementedError
        end
    end

    class SignonResponse < Response
        attr_accessor :date
        attr_accessor :user_key
        attr_accessor :language
        attr_accessor :date_of_last_profile_update
        attr_accessor :date_of_last_account_update
        attr_accessor :financial_institution_identification
        attr_accessor :session_cookie
    end



    class PasswordChangeRequest < TransactionalRequest
        def user_identification
            raise NotImplementedError
        end
    end

    class PasswordChangeResponse < TransactionalResponse
        def user_identification
            raise NotImplementedError
        end

        def date_changed
            raise NotImplementedError
        end
    end



    class ChallengeRequest < Request
        def user_identification
            raise NotImplementedError
        end

        def financial_institution_certificate_identifier
            raise NotImplementedError
        end
    end

    class ChallengeResponse < Response
        def user_identification
            raise NotImplementedError
        end

        def nonce
            raise NotImplementedError
        end

        def financial_institution_certificate_identifier
            raise NotImplementedError
        end
    end
end