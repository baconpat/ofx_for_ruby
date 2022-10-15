require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class OFXParserTest < Minitest::Test
    def test_parse_with_no_newline_after_header
        body = <<-EOS

OFXHEADER:100
DATA:OFXSGML
VERSION:102
SECURITY:NONE
ENCODING:USASCII
CHARSET:1252
COMPRESSION:NONE
OLDFILEUID:NONE
NEWFILEUID:NONE
<OFX>
<SIGNONMSGSRSV1>
<SONRS>
<STATUS>
<CODE>0
<SEVERITY>INFO
</STATUS>
<DTSERVER>20221013120000[0:GMT]
<LANGUAGE>ENG
<FI>
<ORG>B1
<FID>10898
</FI>
<INTU.BID>10898
</SONRS>
</SIGNONMSGSRSV1>
<BANKMSGSRSV1>
<STMTTRNRS>
<TRNUID>1
<STATUS>
<CODE>0
<SEVERITY>INFO
<MESSAGE>Success
</STATUS>
<STMTRS>
<CURDEF>USD
<BANKACCTFROM>
<BANKID>0713456513
<ACCTID>123456788
<ACCTTYPE>CHECKING
</BANKACCTFROM>
<BANKTRANLIST>
<DTSTART>20221003120000[0:GMT]
<DTEND>20221012120000[0:GMT]
<STMTTRN>
<TRNTYPE>DEBIT
<DTPOSTED>20221012120000[0:GMT]
<TRNAMT>-100.01
<FITID>202210120
<NAME>CAPITAL ONE N.A. CAPITALONE 0000
<MEMO>0234345d WEB ID: 15234563
</STMTTRN>
</BANKTRANLIST>
<LEDGERBAL>
<BALAMT>29.03
<DTASOF>20221013120000[0:GMT]
</LEDGERBAL>
<AVAILBAL>
<BALAMT>30.06
<DTASOF>20221013120000[0:GMT]
</AVAILBAL>
</STMTRS>
</STMTTRNRS>
</BANKMSGSRSV1>
</OFX>
EOS

        serializer = OFX::OFX102::Serializer.new
        document = serializer.from_http_response_body(body)

        signon_message_set = document.message_sets[0]
        signon_response = signon_message_set.responses[0]

        banking_statement_message_set = document.message_sets[1]
        banking_statement_response = banking_statement_message_set.responses[0]

        assert_equal '123456788', banking_statement_response.account.account_identifier
        assert_equal '0713456513', banking_statement_response.account.bank_identifier
        assert_equal '30.06', banking_statement_response.available_balance.amount
        assert_equal '29.03', banking_statement_response.ledger_balance.amount

        transactions = banking_statement_response.transactions
        assert_equal 1, transactions.size

        transaction = transactions.first
        assert_equal '-100.01', transaction.amount.to_f.to_s
        assert_equal 'CAPITAL ONE N.A. CAPITALONE 0000', transaction.payee
        assert_equal :debit, transaction.transaction_type
    end

    def test_with_newline_after_header
        body =
"OFXHEADER:100
DATA:OFXSGML
VERSION:102
SECURITY:NONE
ENCODING:USASCII
CHARSET:1252
COMPRESSION:NONE
OLDFILEUID:NONE
NEWFILEUID:NONE

<OFX>
<SIGNONMSGSRSV1>
<SONRS>
<STATUS>
<CODE>0
<SEVERITY>INFO
</STATUS>
<DTSERVER>20221013120000[0:GMT]
<LANGUAGE>ENG
<FI>
<ORG>B1
<FID>10898
</FI>
<INTU.BID>10898
</SONRS>
</SIGNONMSGSRSV1>
<BANKMSGSRSV1>
<STMTTRNRS>
<TRNUID>1
<STATUS>
<CODE>0
<SEVERITY>INFO
<MESSAGE>Success
</STATUS>
<STMTRS>
<CURDEF>USD
<BANKACCTFROM>
<BANKID>0713456513
<ACCTID>123456788
<ACCTTYPE>CHECKING
</BANKACCTFROM>
<BANKTRANLIST>
<DTSTART>20221003120000[0:GMT]
<DTEND>20221012120000[0:GMT]
<STMTTRN>
<TRNTYPE>DEBIT
<DTPOSTED>20221012120000[0:GMT]
<TRNAMT>-100.01
<FITID>202210120
<NAME>CAPITAL ONE N.A. CAPITALONE 0000
<MEMO>0234345d WEB ID: 15234563
</STMTTRN>
</BANKTRANLIST>
<LEDGERBAL>
<BALAMT>29.03
<DTASOF>20221013120000[0:GMT]
</LEDGERBAL>
<AVAILBAL>
<BALAMT>30.06
<DTASOF>20221013120000[0:GMT]
</AVAILBAL>
</STMTRS>
</STMTTRNRS>
</BANKMSGSRSV1>
</OFX>"

        serializer = OFX::OFX102::Serializer.new
        document = serializer.from_http_response_body(body)

        # require 'pp'
        # pp document

        signon_message_set = document.message_sets[0]
        signon_response = signon_message_set.responses[0]

        signon_message_set = document.message_sets[0]
        signon_response = signon_message_set.responses[0]

        banking_statement_message_set = document.message_sets[1]
        banking_statement_response = banking_statement_message_set.responses[0]

        assert_equal '123456788', banking_statement_response.account.account_identifier
        assert_equal '0713456513', banking_statement_response.account.bank_identifier
        assert_equal '30.06', banking_statement_response.available_balance.amount
        assert_equal '29.03', banking_statement_response.ledger_balance.amount

        transactions = banking_statement_response.transactions
        assert_equal 1, transactions.size

        transaction = transactions.first
        assert_equal '-100.01', transaction.amount.to_f.to_s
        assert_equal 'CAPITAL ONE N.A. CAPITALONE 0000', transaction.payee
        assert_equal :debit, transaction.transaction_type
    end
end