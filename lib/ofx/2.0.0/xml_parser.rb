require 'rexml/document'

module OFX
    module OFX200
        class XMLParser
            def self.xml_ofx?(body)
                body.to_s.lstrip =~ /\A(?:<\?xml\b[^?]*\?>\s*)?<\?OFX\b/i ? true : false
            end

            def initialize(body)
                @body = body.to_s.lstrip
            end

            def header
                header = OFX::Header.new
                processing_instruction_attributes.each do |key, value|
                    header[key] = value
                end
                header['DATA'] ||= 'OFXXML'
                header
            end

            def to_document
                document = OFX::Document.from_ofx_hash(to_ofx_hash)
                document.header = header
                document
            end

            def to_ofx_hash
                { document.root.name => element_to_hash_value(document.root) }
            end

            private

            def document
                @document ||= REXML::Document.new(@body)
            end

            def processing_instruction_attributes
                return {} unless ofx_processing_instruction

                attributes = {}
                ofx_processing_instruction.content.scan(/([A-Za-z0-9_.-]+)\s*=\s*("([^"]*)"|'([^']*)')/) do |match|
                    attributes[match[0]] = match[2] || match[3]
                end
                attributes
            end

            def ofx_processing_instruction
                document.children.find do |child|
                    child.is_a?(REXML::Instruction) && child.target.upcase == 'OFX'
                end
            end

            def element_to_hash_value(element)
                children = element.elements.to_a
                return element.text.to_s.strip if children.empty?

                hash = {}
                children.each do |child|
                    append_child(hash, child.name, element_to_hash_value(child))
                end
                hash
            end

            def append_child(hash, name, value)
                previous = hash[name]
                if previous.nil?
                    hash[name] = value
                elsif previous.kind_of?(Array)
                    previous << value
                else
                    hash[name] = [previous, value]
                end
            end
        end
    end
end