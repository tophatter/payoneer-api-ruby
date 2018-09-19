module Payoneer
  class Configuration
    attr_reader :partner_id, :username, :api_password, :auto_approve_sandbox_accounts, :http_client_options

    def initialize(partner_id:, username:, api_password:, environment: 'development', auto_approve_sandbox_accounts: true, http_client_options: {})
      @partner_id                    = partner_id
      @username                      = username
      @api_password                  = api_password
      @host                          = 'api.sandbox.payoneer.com' if environment != 'production'
      @auto_approve_sandbox_accounts = auto_approve_sandbox_accounts && environment != 'production'
      @http_client_options           = http_client_options
    end

    def protocol
      @protocol || 'https'
    end

    def host
      @host || 'api.payoneer.com'
    end

    def xml_base_uri
      @xml_base_uri || "#{protocol}://#{host}/Payouts/HttpApi/API.aspx"
    end

    def json_base_uri
      @json_base_uri || "#{protocol}://#{host}/v2/programs/#{@partner_id}"
    end
  end
end
