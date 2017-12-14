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
        hash = if block_given?
          yield(hash)
        else
          hash
        end

        Response.new(Response::OK_STATUS_CODE, hash)
      end
    end
  end
end
