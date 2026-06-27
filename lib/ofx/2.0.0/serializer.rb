require File.dirname(__FILE__) + '/../1.0.2/serializer'
require File.dirname(__FILE__) + '/xml_parser'

module OFX
    module OFX200
        class Serializer
            def self.xml_ofx?(body)
                OFX::OFX200::XMLParser.xml_ofx?(body)
            end

            def from_http_response_body(body)
                body = body.to_s.lstrip
                unless self.class.xml_ofx?(body)
                    raise NotImplementedError, 'OFX 2.x serializer only supports XML OFX documents'
                end

                OFX::OFX200::XMLParser.new(body).to_document
            end

            def to_http_post_body(document)
                raise NotImplementedError
            end
        end
    end
end