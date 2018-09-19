module Payoneer
  class Configuration
    attr_reader :partner_id, :username, :api_password, :auto_approve_sandbox_accounts, :http_client_options

    def initialize(partner_id:, username:, api_password:, environment: 'development', protocol: 'https', host: nil, http_client_options: {}, auto_approve_sandbox_accounts: true)
      @partner_id                    = partner_id
      @username                      = username
      @api_password                  = api_password
      @environment                   = environment

      @protocol                      = protocol
      @host                          = host || default_host
      @http_client_options           = http_client_options

      @auto_approve_sandbox_accounts = auto_approve_sandbox_accounts && environment != 'production'
    end

    def xml_base_uri
      "#{@protocol}://#{@host}/Payouts/HttpApi/API.aspx"
    end

    def json_base_uri
      "#{@protocol}://#{@host}/v2/programs/#{@partner_id}"
    end

    private

    def default_host
      if @environment == 'production'
        'api.payoneer.com'
      else
        'api.sandbox.payoneer.com'
      end
    end
  end
end
