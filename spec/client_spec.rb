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
  let(:default_config_options) { { username: 'fake-username', api_password: 'fake-password', partner_id: 'fake-partner-id', environment: 'production' } }
  let(:config_options) { default_config_options }
  let(:configuration) { Payoneer::Configuration.new(config_options) }
  let(:client) { Payoneer::Client.new(configuration) }

  describe '#status' do
    context 'when the response is valid' do
      let(:xml) { "<?xml version='1.0' encoding='ISO-8859-1' ?><PayoneerResponse><Status>000</Status><Description>Echo Ok - All systems are up.</Description></PayoneerResponse>" }

      it 'returns a successful response' do
        expect(RestClient::Request).to receive(:execute).exactly(1).times.with(method: :post, url: endpoint, payload: hash_including(mname: 'Echo')).and_return(response)
        response = client.status
        expect(response.ok?).to be_truthy
        expect(response.body['Description']).to eq('Echo Ok - All systems are up.')
      end
    end

    context 'when the response specifies a non-200 code' do
      let(:xml) { "<?xml version='1.0' encoding='ISO-8859-1' ?><PayoneerResponse><Code>999</Code><Description>Echo Failure - All systems are down.</Description></PayoneerResponse>" }

      it 'returns a failure response' do
        expect(RestClient::Request).to receive(:execute).exactly(1).times.with(method: :post, url: endpoint, payload: hash_including(mname: 'Echo')).and_return(response)
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
        expect(RestClient::Request).to receive(:execute).exactly(1).times.with(method: :post, url: endpoint, payload: hash_including(mname: 'Echo')).and_return(response)
        expect { client.status }.to raise_error(Payoneer::ResponseError)
      end
    end
  end

  describe '#version' do
    let(:xml) { "<?xml version='1.0' encoding='ISO-8859-1' ?><PayoneerResponse><Version>4.15</Version></PayoneerResponse>" }

    it 'generates the correct request' do
      expect(RestClient::Request).to receive(:execute).exactly(1).times.with(method: :post, url: endpoint, payload: hash_including(mname: 'GetVersion')).and_return(response)
      response = client.version
      expect(response.ok?).to be_truthy
      expect(response.body['Version']).to eq('4.15')
    end
  end

  describe '#payee_signup_url' do
    let(:xml) { '<?xml version="1.0" encoding="UTF-8" ?><PayoneerToken><Token>https://payouts.sandbox.payoneer.com/partners/lp.aspx?token=fake-token</Token></PayoneerToken>' }

    it 'generates the correct request' do
      expect(RestClient::Request).to receive(:execute).exactly(1).times.with(method: :post, url: endpoint, payload: hash_including(mname: 'GetToken')).and_return(response)
      response = client.payee_signup_url('test')
      expect(response.ok?).to be_truthy
      expect(response.body).to eq('https://payouts.sandbox.payoneer.com/partners/lp.aspx?token=fake-token')
    end
  end

  describe '#payee_details' do
    let(:xml) { '<?xml version="1.0" encoding="ISO-8859-1" standalone="yes"?><GetPayeeDetails><Payee><FirstName>Foo</FirstName><LastName>Bar</LastName><Email>foo@bar.com</Email><Address1>185 Berry Street</Address1><Address2>Suite 2400</Address2><City>San Francisco</City><State>CA</State><Zip>94107</Zip><Country>US</Country><Phone></Phone><Mobile>15552223333</Mobile><PayeeStatus>Active</PayeeStatus><PayOutMethod>Prepaid Card</PayOutMethod><Cards><Card><CardID>123456789</CardID><Currency>USD</Currency><ActivationStatus>Card Issued, Not Activated</ActivationStatus><CardShipDate>11/25/2015</CardShipDate><CardStatus>Active</CardStatus></Card></Cards><RegDate>10/9/2017 7:58:44 PM</RegDate></Payee><CompanyDetails><CompanyName></CompanyName></CompanyDetails></GetPayeeDetails>' }

    it 'generates the correct request' do
      expect(RestClient::Request).to receive(:execute).exactly(1).times.with(method: :post, url: endpoint, payload: hash_including(mname: 'GetPayeeDetails')).and_return(response)
      response = client.payee_details('fake-payee-id')
      expect(response.ok?).to be_truthy
      expect(response.body).to include('FirstName' => 'Foo', 'LastName' => 'Bar')
    end
  end

  describe '#expanded_payout' do
    let(:payee_id) { 42 }
    let(:client_reference_id) { 43 }
    let(:amount) { 100 }
    let(:currency) { 'USD' }
    let(:description) { (Time.now - 10.days).strftime('%Y-%m-%d') }
    let(:seller_id) { 44 }
    let(:seller_name) { 'Fake Seller' }
    let(:seller_url) { 'http://tophatter.dev/users/1' }
    let(:path) { 'fake_s3@path.com' }
    let(:credentials) { { type: 'AUTHORIZATION', token: 'fake' } }
    let(:endpoint) { "#{configuration.json_base_uri}/payouts" }
    let(:headers) { { content_type: 'application/json', accept: :json, Authorization: 'Basic ' + Base64.encode64("#{configuration.username}:#{configuration.api_password}").chomp } }
    let(:response) do
      mock = double
      allow(mock).to receive(:code).and_return(200)
      allow(mock).to receive(:body).and_return(params.to_json)
      mock
    end

    let(:params) do
      { payee_id: payee_id,
        client_reference_id: client_reference_id,
        amount: amount,
        currency: 'USD',
        description: description,
        payout_date: Time.now.strftime('%Y-%m-%d'),
        orders_report: {
          merchant: {
            id: seller_id,
            store: {
              name: seller_name,
              url: seller_url,
              type: 'ECOMMERCE'
            }
          },
          orders: {
            type: 'url',
            path: path,
            credentials: credentials
          }
        } }
    end

    it 'generates the correct response' do
      expect(RestClient::Request).to receive(:execute).exactly(1).times.with(method: :post, url: endpoint, payload: params.to_json, headers: headers).and_return(response)
      response = client.expanded_payout(payee_id: payee_id, client_reference_id: client_reference_id, amount: amount, description: description, currency: currency, seller_id: seller_id, seller_name: seller_name, seller_url: seller_url, path: path, credentials: credentials)
      expect(response.ok?).to be_truthy
      expect(response.body).to include('payee_id' => payee_id, 'amount' => amount)
      expect(response.body).to include('orders_report')
      expect(response.body['orders_report']).to include('orders')
      expect(response.body['orders_report']['orders']).to include('path' => path)
    end
  end

  describe 'configuration' do
    let(:xml) { "<?xml version='1.0' encoding='ISO-8859-1' ?><PayoneerResponse><Status>000</Status><Description>Echo Ok - All systems are up.</Description></PayoneerResponse>" }

    describe 'http_client_options' do
      let(:config_options) { default_config_options.merge(http_client_options: { verify_ssl: true }) }
      it 'passes HTTP client options to HTTP client' do
        expect(RestClient::Request).to receive(:execute).with(hash_including(verify_ssl: true)).and_return(response)
        client.status
      end
    end

    describe 'host' do
      let(:config_options) { default_config_options.merge(host: 'api.example.com') }
      it 'allows using a custom API host' do
        expected_url = 'https://api.example.com/Payouts/HttpApi/API.aspx'
        expect(RestClient::Request).to receive(:execute).with(hash_including(url: expected_url)).and_return(response)
        client.status
      end
    end
  end
end
