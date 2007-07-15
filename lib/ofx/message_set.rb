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

    class MessageSet
        def precedence
            raise NotImplementedError
        end

        def version
            raise NotImplementedError
        end

        def requests
            @requests ||= []
        end

        def responses
            @responses ||= []
        end
    end

    class MessageSetProfile
        attr_accessor :message_set_class
        attr_accessor :version
        attr_accessor :service_provider_name
        attr_accessor :message_url
        attr_accessor :required_ofx_security
        attr_accessor :requires_transport_security
        def requires_transport_security?
            @requires_transport_security
        end
        attr_accessor :signon_realm
        attr_accessor :language
        attr_accessor :synchronization_mode
        attr_accessor :supports_response_file_error_recovery
        def supports_response_file_error_recovery?
            @supports_response_file_error_recovery
        end
    end
    
    class Request
        def satisfies_requirements?
            raise NotImplementedError
        end
    end

    class TransactionalRequest < Request
        attr_accessor :transaction_identifier
        attr_accessor :client_cookie
        attr_accessor :transaction_authorization_number
    end

    class Response
        attr_accessor :status
    end

    class TransactionalResponse < Response
        attr_accessor :transaction_identifier
        attr_accessor :client_cookie
    end

end