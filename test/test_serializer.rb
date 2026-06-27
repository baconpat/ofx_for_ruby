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

        document = OFX::Serializer.from_http_response_body(body)

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

    def test_capitalone_ofx
        body = <<-EOS
<?xml version="1.0" encoding="utf-8"?><?OFX OFXHEADER="200" VERSION="220" SECURITY="NONE" OLDFILEUID="NONE" NEWFILEUID="NONE"?><OFX><SIGNONMSGSRSV1><SONRS><STATUS><CODE>0</CODE><SEVERITY>INFO</SEVERITY></STATUS><DTSERVER>20260627111438.091[-4:EDT]</DTSERVER><LANGUAGE>ENG</LANGUAGE><FI><ORG>Capital One Bank</ORG><FID>1001</FID></FI><INTU.BID>1236</INTU.BID></SONRS></SIGNONMSGSRSV1><BANKMSGSRSV1><STMTTRNRS><TRNUID>0</TRNUID><STATUS><CODE>0</CODE><SEVERITY>INFO</SEVERITY></STATUS><STMTRS><CURDEF>USD</CURDEF><BANKACCTFROM><BANKID>0123456789</BANKID><ACCTID>1234</ACCTID><ACCTTYPE>SAVINGS</ACCTTYPE></BANKACCTFROM><BANKTRANLIST><DTSTART>20260528000000.000[-4:EDT]</DTSTART><DTEND>20260627000000.000[-4:EDT]</DTEND><STMTTRN><TRNTYPE>CREDIT</TRNTYPE><DTPOSTED>20260626000000.000[-4:EDT]</DTPOSTED><TRNAMT>115</TRNAMT><FITID>20260626405</FITID><MEMO>Deposit from SOME PAYROLL</MEMO></STMTTRN></BANKTRANLIST><LEDGERBAL><BALAMT>200.31</BALAMT><DTASOF>20260627111438.091[-4:EDT]</DTASOF></LEDGERBAL></STMTRS></STMTTRNRS></BANKMSGSRSV1></OFX>
EOS

        document = OFX::Serializer.from_http_response_body(body)

        assert_equal OFX::Version.new('2.0.0'), document.header.header_version
        assert_equal 'OFXXML', document.header.content_type
        assert_equal OFX::Version.new('2.2.0'), document.header.document_version
        assert_equal 'NONE', document.header.security
        assert_equal 'NONE', document.header.previous_unique_identifier
        assert_equal 'NONE', document.header.unique_identifier

        signon_message_set = document.message_sets[0]
        signon_response = signon_message_set.responses[0]

        assert_equal 0, signon_response.status.code
        assert_equal :information, signon_response.status.severity
        assert_equal '20260627111438', signon_response.date.strftime('%Y%m%d%H%M%S')
        assert_equal 'ENG', signon_response.language
        assert_equal 'Capital One Bank', signon_response.financial_institution_identification.organization
        assert_equal '1001', signon_response.financial_institution_identification.financial_institution_identifier

        banking_statement_message_set = document.message_sets[1]
        banking_statement_response = banking_statement_message_set.responses[0]

        assert_equal '0', banking_statement_response.transaction_identifier
        assert_equal 0, banking_statement_response.status.code
        assert_equal :information, banking_statement_response.status.severity
        assert_equal 'USD', banking_statement_response.default_currency
        assert_equal '1234', banking_statement_response.account.account_identifier
        assert_equal '0123456789', banking_statement_response.account.bank_identifier
        assert_equal :savings, banking_statement_response.account.account_type
        assert_nil banking_statement_response.available_balance
        assert_equal '200.31', banking_statement_response.ledger_balance.amount
        assert_equal '20260627111438', banking_statement_response.ledger_balance.as_of.strftime('%Y%m%d%H%M%S')
        assert_equal '20260528000000', banking_statement_response.transaction_range.begin.strftime('%Y%m%d%H%M%S')
        assert_equal '20260627000000', banking_statement_response.transaction_range.end.strftime('%Y%m%d%H%M%S')

        transactions = banking_statement_response.transactions
        assert_equal 1, transactions.size

        transaction = transactions.first
        assert_equal '115'.to_d, transaction.amount
        assert_equal 'USD', transaction.currency
        assert_equal '20260626000000', transaction.date_posted.strftime('%Y%m%d%H%M%S')
        assert_equal '20260626405', transaction.financial_institution_transaction_identifier
        assert_nil transaction.payee
        assert_equal 'Deposit from SOME PAYROLL', transaction.memo
        assert_equal :credit, transaction.transaction_type
    end
end