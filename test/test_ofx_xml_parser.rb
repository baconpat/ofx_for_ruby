require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class OFXXMLParserTest < Minitest::Test
    XML_OFX = '<?xml version="1.0" encoding="utf-8"?><?OFX OFXHEADER="200" VERSION="220" SECURITY="NONE" OLDFILEUID="NONE" NEWFILEUID="NONE"?><OFX><SIGNONMSGSRSV1><SONRS><STATUS><CODE>0</CODE><SEVERITY>INFO</SEVERITY></STATUS><DTSERVER>20260627111438.091[-4:EDT]</DTSERVER><LANGUAGE>ENG</LANGUAGE><FI><ORG>Capital One Bank</ORG><FID>1001</FID></FI><INTU.BID>1236</INTU.BID></SONRS></SIGNONMSGSRSV1><BANKMSGSRSV1><STMTTRNRS><STMTRS><BANKTRANLIST><STMTTRN><FITID>1</FITID></STMTTRN><STMTTRN><FITID>2</FITID></STMTTRN></BANKTRANLIST></STMTRS></STMTTRNRS></BANKMSGSRSV1></OFX>'

    def test_detects_xml_ofx_documents
        assert OFX::OFX200::XMLParser.xml_ofx?(XML_OFX)
        refute OFX::OFX200::XMLParser.xml_ofx?("OFXHEADER:100\nDATA:OFXSGML\n<OFX></OFX>")
    end

    def test_parses_processing_instruction_header
        header = OFX::OFX200::XMLParser.new(XML_OFX).header

        assert_equal OFX::Version.new('2.0.0'), header.header_version
        assert_equal 'OFXXML', header.content_type
        assert_equal OFX::Version.new('2.2.0'), header.document_version
        assert_equal 'NONE', header.security
        assert_equal 'NONE', header.previous_unique_identifier
        assert_equal 'NONE', header.unique_identifier
    end

    def test_converts_xml_tree_to_ofx_hash
        ofx_hash = OFX::OFX200::XMLParser.new(XML_OFX).to_ofx_hash

        sonrs = ofx_hash['OFX']['SIGNONMSGSRSV1']['SONRS']
        assert_equal '0', sonrs['STATUS']['CODE']
        assert_equal 'INFO', sonrs['STATUS']['SEVERITY']
        assert_equal '20260627111438.091[-4:EDT]', sonrs['DTSERVER']
        assert_equal 'Capital One Bank', sonrs['FI']['ORG']
        assert_equal '1236', sonrs['INTU.BID']
    end

    def test_repeated_xml_tags_become_arrays
        ofx_hash = OFX::OFX200::XMLParser.new(XML_OFX).to_ofx_hash
        transactions = ofx_hash['OFX']['BANKMSGSRSV1']['STMTTRNRS']['STMTRS']['BANKTRANLIST']['STMTTRN']

        assert_equal [{'FITID' => '1'}, {'FITID' => '2'}], transactions
    end

    def test_top_level_serializer_get_returns_ofx200_serializer_for_ofx2_versions
        assert_instance_of OFX::OFX200::Serializer, OFX::Serializer.get(OFX::Version.new('2.2.0'))
    end
end