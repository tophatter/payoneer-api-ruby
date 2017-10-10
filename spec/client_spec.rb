require 'spec_helper'

# rspec spec/client_spec.rb
describe Payoneer::Client do
  let(:response) do
    mock = double
    allow(mock).to receive(:code).and_return(200)
    allow(mock).to receive(:body).and_return(xml)
    mock
  end

  let(:endpoint) { 'https://api.payoneer.com/Payouts/HttpApi/API.aspx' }
  let(:configuration) { Payoneer::Configuration.new(username: 'fake-username', api_password: 'fake-password', partner_id: 'fake-partner-id', environment: 'production') }
  let(:client) { Payoneer::Client.new(configuration) }

  describe '#status' do
    context 'when the response is valid' do
      let(:xml) { "<?xml version='1.0' encoding='ISO-8859-1' ?><PayoneerResponse><Status>000</Status><Description>Echo Ok - All systems are up.</Description></PayoneerResponse>" }

      it 'returns a successful response' do
        expect(RestClient).to receive(:post).exactly(1).times.with(endpoint, hash_including(mname: 'Echo')).and_return(response)
        response = client.status
        expect(response.ok?).to be_truthy
        expect(response.body['Description']).to eq('Echo Ok - All systems are up.')
      end
    end

    context 'when the response specifies a non-200 code' do
      let(:xml) { "<?xml version='1.0' encoding='ISO-8859-1' ?><PayoneerResponse><Code>999</Code><Description>Echo Failure - All systems are down.</Description></PayoneerResponse>" }

      it 'returns a failure response' do
        expect(RestClient).to receive(:post).exactly(1).times.with(endpoint, hash_including(mname: 'Echo')).and_return(response)
        response = client.status
        expect(response.ok?).to be_falsey
        expect(response.body).to eq('Echo Failure - All systems are down.')
      end
    end

    context 'when the response is invalid' do
      let(:response) do
        mock = double
        allow(mock).to receive(:code).and_return(500)
        allow(mock).to receive(:body).and_return('Server Error')
        mock
      end

      it 'raises an error' do
        expect(RestClient).to receive(:post).exactly(1).times.with(endpoint, hash_including(mname: 'Echo')).and_return(response)
        expect { client.status }.to raise_error(Payoneer::ResponseError)
      end
    end
  end

  describe '#version' do
    let(:xml) { "<?xml version='1.0' encoding='ISO-8859-1' ?><PayoneerResponse><Version>4.15</Version></PayoneerResponse>" }

    it 'generates the correct request' do
      expect(RestClient).to receive(:post).exactly(1).times.with(endpoint, hash_including(mname: 'GetVersion')).and_return(response)
      response = client.version
      expect(response.ok?).to be_truthy
      expect(response.body['Version']).to eq('4.15')
    end
  end

  describe '#payee_signup_url' do
    let(:xml) { '<?xml version="1.0" encoding="UTF-8" ?><PayoneerToken><Token>https://payouts.sandbox.payoneer.com/partners/lp.aspx?token=fake-token</Token></PayoneerToken>' }

    it 'generates the correct request' do
      expect(RestClient).to receive(:post).exactly(1).times.with(endpoint, hash_including(mname: 'GetToken')).and_return(response)
      response = client.payee_signup_url('test')
      expect(response.ok?).to be_truthy
      expect(response.body).to eq('https://payouts.sandbox.payoneer.com/partners/lp.aspx?token=fake-token')
    end
  end

  describe '#payee_details' do
    let(:xml) { '<?xml version="1.0" encoding="ISO-8859-1" standalone="yes"?><GetPayeeDetails><Payee><FirstName>Foo</FirstName><LastName>Bar</LastName><Email>foo@bar.com</Email><Address1>185 Berry Street</Address1><Address2>Suite 2400</Address2><City>San Francisco</City><State>CA</State><Zip>94107</Zip><Country>US</Country><Phone></Phone><Mobile>15552223333</Mobile><PayeeStatus>Active</PayeeStatus><PayOutMethod>Prepaid Card</PayOutMethod><Cards><Card><CardID>123456789</CardID><Currency>USD</Currency><ActivationStatus>Card Issued, Not Activated</ActivationStatus><CardShipDate>11/25/2015</CardShipDate><CardStatus>Active</CardStatus></Card></Cards><RegDate>10/9/2017 7:58:44 PM</RegDate></Payee><CompanyDetails><CompanyName></CompanyName></CompanyDetails></GetPayeeDetails>' }

    it 'generates the correct request' do
      expect(RestClient).to receive(:post).exactly(1).times.with(endpoint, hash_including(mname: 'GetPayeeDetails')).and_return(response)
      response = client.payee_details('fake-payee-id')
      expect(response.ok?).to be_truthy
      expect(response.body).to include('FirstName' => 'Foo', 'LastName' => 'Bar')
    end
  end
end
