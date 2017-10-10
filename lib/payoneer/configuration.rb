module Payoneer
  class Configuration
    attr_reader :partner_id, :username, :api_password, :auto_approve_sandbox_accounts

    def initialize(partner_id:, username:, api_password:, environment: 'development', auto_approve_sandbox_accounts: true)
      @partner_id                    = partner_id
      @username                      = username
      @api_password                  = api_password
      @host                          = 'api.sandbox.payoneer.com' if environment != 'production'
      @auto_approve_sandbox_accounts = auto_approve_sandbox_accounts && environment != 'production'
    end

    def protocol
      @protocol || 'https'
    end

    def host
      @host || 'api.payoneer.com'
    end

    def base_uri
      @base_uri || "#{protocol}://#{host}/Payouts/HttpApi/API.aspx"
    end
  end
end
