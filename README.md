[![Build Status](https://travis-ci.org/tophatter/payoneer-api-ruby.svg?branch=master)](https://travis-ci.org/tophatter/payoneer-api-ruby)
[![Coverage Status](https://coveralls.io/repos/github/tophatter/payoneer-api-ruby/badge.svg?branch=master)](https://coveralls.io/github/tophatter/payoneer-api-ruby?branch=master)

### Payoneer SDK for Ruby:

#### Install:

```
gem install payoneer-client
```

#### Usage:

```ruby
client = Payoneer::Client.new(
  Payoneer::Configuration.new(
    username: 'fake-username',
    api_password: 'fake-api-password',
    partner_id: 'fake-partner-id'
  )
)
=> <Payoneer::Client @configuration=<Payoneer::Configuration @partner_id="fake-partner-id", @username="fake-username", @api_password="fake-api-password", @host="api.sandbox.payoneer.com", @auto_approve_sandbox_accounts=true>>

response = client.status
response.ok?
=> true

response.body
=> {
         "Status" => "000",
    "Description" => "Echo Ok - All systems are up."
}

client.version.body
=> {
    "Version" => "4.15"
}

client.payee_signup_url('test').body
=> "https://payouts.sandbox.payoneer.com/partners/lp.aspx?token=fake-token"

client.payee_details('fake-payee-id').body
=> {"FirstName"=>"Foo",
  "LastName"=>"Bar",
  "Email"=>"foo@bar.com",
  "Address1"=>"123 Main Street",
  "Address2"=>nil,
  "City"=>"Palo Alto",
  "State"=>"CA",
  "Zip"=>"94306",
  "Country"=>"US",
  "Phone"=>"555-867-5309",
  "Mobile"=>nil,
  "PayeeStatus"=>"InActive",
  "PayOutMethod"=>"Direct Deposit",
  "RegDate"=>"12/21/2015 8:03:19 PM",
  "PayoutMethodDetails"=>
   {"Currency"=>"USD",
    "Country"=>"US",
    "BankAccountType"=>"Individual",
    "BankName"=>"Wells Fargo",
    "AccountName"=>"Foo Bar",
    "AccountNumber"=>"123456789",
    "RoutingNumber"=>"121042882",
    "AccountType"=>"S"}}
    
```

##### Performing a payout with expanded params:
`credentials_type` must be either `"AUTHORIZATION"` or `"PASSWORD"`
- If `credentials_type` is `"AUTHORIZATION"`, `token` is required
- If `credentials_type` is `"PASSWORD"`, `user_name` and `password` are required
```ruby
client.expanded_payout(
  payee_id: 42,
  client_reference_id: 43,
  amount: 100.0, 
  description: "Foo Bar's order",
  seller_id: 44, 
  seller_name: "Foo Bar", 
  seller_url: "foo@bar.com", 
  seller_type: 'ECOMMERCE', 
  path: 'orders@path.com', 
  credentials_type: 'AUTHORIZATION', 
  token: 'fake_token'
)
```

#### Console:

After checking out the repo, run `bin/payoneer-console` for an interactive console that will allow you to experiment.
