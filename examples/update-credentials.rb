# This example updates the credentials from the create credentials example.
#
# To run this example:
#
# 1. Append the path to your .edgerc file and the section header of the set of credentials to use.
#
# The defaults here expect the .edgerc at your home directory and use the credentials under the heading of default.
#
# 2. Add the credentialId for the set of credentials created using the create example as a path parameter.
#
# 3. Edit the expiresOn date to today's date. Optionally, you can change the description value.
#
# 4. Open a Terminal or shell instance and run "ruby examples/update-credentials.rb".
#
# A successful call returns.
#
# For more information on the call used in this example, see https://techdocs.akamai.com/iam-api/reference/put-self-credential.

require 'akamai/edgegrid'
require 'net/http'
require 'uri'
require "json"

http = Akamai::Edgegrid::HTTP.new(get_host(), 443)
https.use_ssl = true

baseuri = URI('https://' + http.host)

http.setup_from_edgerc(
    :filename => '~/.edgerc',
    :section => 'default'
)

credential_id = 123456

request = Net::HTTP::Put.new(URI.join(baseuri.to_s, 'identity-management/v3/api-clients/self/credentials/#{credential_id}').to_s)
request["Accept"] = "application/json"
request["Content-Type"] = "application/json"
request.body = JSON.dump({
  "description": "Update this credential",
  "expiresOn": "2024-06-11T23:06:59.000Z", # # the date cannot be more than two years out or it will return a 400
  "status": "ACTIVE"
})

response = http.request(request)
puts response.read_body
