# This example deletes your API client credentials.
#
# To run this example:
#
# 1. Append the path to your .edgerc file and the section header of the set of credentials to use.
#
# The defaults here expect the .edgerc at your home directory and use the credentials under the heading of default.
#
# 2. Add the credentialId from the update example to the path. You can only delete inactive credentials. Sending the request on an active set will return a 400. Use the update credentials example for deactivation.
#
# 3. Open a Terminal or shell instance and run "ruby examples/delete-credentials.rb".
#
# A successful call returns "" null.
#
# For more information on the call used in this example, see https://techdocs.akamai.com/iam-api/reference/delete-self-credential.

require 'akamai/edgegrid'
require 'net/http'
require 'uri'

http = Akamai::Edgegrid::HTTP.new(get_host(), 443)
https.use_ssl = true

baseuri = URI('https://' + http.host)

http.setup_from_edgerc(
    :filename => '~/.edgerc',
    :section => 'default'
)

credential_id = 123456

request = Net::HTTP::Delete.new(URI.join(baseuri.to_s, 'identity-management/v3/api-clients/self/credentials/#{credential_id}').to_s)
request["Accept"] = "application/json"

response = http.request(request)
puts response.read_body