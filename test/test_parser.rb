require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class OFXParserTest < Minitest::Test

    def test_creating_from_array
      body = <<-EOS
      <OFX><SIGNONMSGSRSV1><SONRS><STATUS><CODE>0<SEVERITY>INFO<MESSAGE>SUCCESS</STATUS><DTSERVER>20151223151556.657[-5:EST]<LANGUAGE>ENG<FI><ORG>AB<FID>12345</FI></SONRS></SIGNONMSGSRSV1><BANKMSGSRSV1><STMTTRNRS><TRNUID>20151223151555<STATUS><CODE>0<SEVERITY>INFO</STATUS><CLTCOOKIE>1<STMTRS><CURDEF>USD<BANKACCTFROM><BANKID>071234513<ACCTID>9876543123547<ACCTTYPE>CHECKING</BANKACCTFROM><BANKTRANLIST><DTSTART>20131223151557.601[-5:EST]<DTEND>20151222190000.000[-5:EST]<STMTTRN><TRNTYPE>CHECK<DTPOSTED>20151221120000[0:GMT]<TRNAMT>370.99<FITID>211111110<CHECKNUM>1<NAME>REMOTE ONLINE DEPOSIT #<MEMO>1</STMTTRN></BANKTRANLIST><LEDGERBAL><BALAMT>1000.35<DTASOF>20151222190000.000[-5:EST]</LEDGERBAL><AVAILBAL><BALAMT>1200.09<DTASOF>20151221190000.000[-5:EST]</AVAILBAL></STMTRS></STMTTRNRS></BANKMSGSRSV1></OFX>
      EOS
      parser = OFX::OFX102::Parser.new

      parser.scan_str body

      # require 'pp'
      # pp parser.ofx_hashes[0]

      document = parser.documents[0]

      signon_message_set = document.message_sets[0]
      signon_response = signon_message_set.responses[0]

      banking_statement_message_set = document.message_sets[1]
      banking_statement_response = banking_statement_message_set.responses[0]

      assert_equal '9876543123547', banking_statement_response.account.account_identifier
      assert_equal '071234513', banking_statement_response.account.bank_identifier
      assert_equal '1200.09', banking_statement_response.available_balance.amount
      assert_equal '1000.35', banking_statement_response.ledger_balance.amount

      transactions = banking_statement_response.transactions
      assert_equal 1, transactions.size

      transaction = transactions.first
      assert_equal '370.99', transaction.amount.to_f.to_s
      assert_equal 'REMOTE ONLINE DEPOSIT #', transaction.payee
      assert_equal :check, transaction.transaction_type
    end
end
