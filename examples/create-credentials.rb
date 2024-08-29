# # This example creates your new API client credentials.
#
# To run this example:
#
# 1. Specify the location of your .edgerc file and the section header of the set of credentials to use.
#
## The defaults here expect the .edgerc at your home directory and use the credentials under the heading of default.
#
# 2. Open a Terminal or shell instance and run "ruby examples/create-credentials.rb".
#
# A successful call returns a new API client with its credentialId. Use this ID in both the update and delete examples.
#
# For more information on the call used in this example, see https://techdocs.akamai.com/iam-api/reference/post-self-credentials.

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

request = Net::HTTP::Post.new(URI.join(baseuri.to_s, 'identity-management/v3/api-clients/self/credentials').to_s)
request["Accept"] = "application/json"

response = http.request(request)
puts response.read_body
