### Install

```
gem install payoneer-client
```

### Usage

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

### Development

After checking out the repo, run `bin/payoneer-console` for an interactive prompt that will allow you to experiment.
