module Payoneer
  class Client
    attr_reader :configuration

    def initialize(configuration)
      @configuration = configuration
    end

    def status
      post('Echo')
    end

    def version
      post('GetVersion')
    end

    def payee_signup_url(payee_id, redirect_url: nil, redirect_time: nil)
      post('GetToken', p4: payee_id, p6: redirect_url, p8: redirect_time, p9: configuration.auto_approve_sandbox_accounts, p10: true) do |response|
        response['Token']
      end
    end

    def payee_details(payee_id)
      post('GetPayeeDetails', p4: payee_id, p10: true) do |response|
        response['CompanyDetails'].present? ? response['Payee'].merge(response['CompanyDetails']) : response['Payee']
      end
    end

    def payout(program_id:, payment_id:, payee_id:, amount:, description:, payment_date: Time.now, currency: 'USD')
      post(
        'PerformPayoutPayment',
        p4: program_id,
        p5: payment_id,
        p6: payee_id,
        p7: format('%.2f', amount),
        p8: description,
        p9: payment_date.strftime('%m/%d/%Y %H:%M:%S'),
        Currency: currency
      )
    end

    # Includes additional items as needed to be Payoneer SAFE compliant
    def expanded_payout(payee_id:, client_reference_id:, amount:, currency: 'USD', description:, payout_date: Time.now, seller_id:, seller_name:, seller_url:, seller_type: 'ECOMMERCE', path:, credentials_type:, token: '', user_name: '', password: '')
      params = {
        payee_id: payee_id,
        client_reference_id: client_reference_id,
        amount: amount,
        currency: currency,
        description: description,
        payout_date: payout_date.strftime('%Y-%m-%d'),
        orders_report: {
          merchant: {
            id: seller_id,
            store: {
              name: seller_name,
              url: seller_url,
              type: seller_type
            }
          },
          orders: {
            type: 'url',
            path: path,
            credentials: {
              type: credentials_type,
              token: token,
              user_name: user_name,
              password: password
            }
          }
        }
      }

      encoded_credentials = 'Basic ' + Base64.encode64("#{configuration.username}:#{configuration.api_password}").chomp
      response = RestClient.post "#{configuration.json_base_uri}/payouts", params.to_json, content_type: 'application/json', accept: :json, Authorization: encoded_credentials
      raise ResponseError.new(code: response.code, body: response.body) if response.code != 200

      hash = JSON.parse(response.body)
      hash['PaymentID'] = hash['payout_id'] # Keep consistent with the normal payout response body

      if hash.key?('Code')
        Response.new(hash['Code'], hash['Description'])
      else
        hash = block_given? ? yield(hash) : hash
        Response.new(Response::OK_STATUS_CODE, hash)
      end
    end

    def payout_details(payee_id:, payment_id:)
      post('GetPaymentStatus', p4: payee_id, p5: payment_id)
    end

    private

    def post(method_name, params = {})
      response = RestClient.post(configuration.xml_base_uri, {
        mname: method_name,
        p1: configuration.username,
        p2: configuration.api_password,
        p3: configuration.partner_id
      }.merge(params))

      raise ResponseError.new(code: response.code, body: response.body) if response.code != 200

      # @TODO: Validate that the response is XML?
      hash = Hash.from_xml(response.body).values.first

      if hash.key?('Code')
        Response.new(hash['Code'], hash['Description'])
      else
        hash = block_given? ? yield(hash) : hash
        Response.new(Response::OK_STATUS_CODE, hash)
      end
    end
  end
end
