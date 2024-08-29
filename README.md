# EdgeGrid for Ruby

This library implements an Authentication handler for HTTP requests using the [Akamai EdgeGrid Authentication](https://techdocs.akamai.com/developer/docs/set-up-authentication-credentials) scheme for the Ruby [Net/Http](http://www.ruby-doc.org/stdlib-1.9.3/libdoc/net/http/rdoc/Net/HTTP.html) library.

## Install

This library requires Ruby v1.9 or later. To easily install we
recommend using [rbenv](https://github.com/sstephenson/rbenv), [rubygems](http://rubygems.org/), and [bundler](http://bundler.io/).

* Install from rubygems.
  
  ```bash
  gem install akamai-edgegrid
  ```

* Install from sources (we assume you already have rbenv going).
  
  ```bash
  rbenv local 2.5.3
  gem install bundler
  bundle install
  rake test
  gem build akamai-edgegrid.gemspec
  gem install akamai-edgegrid-1.0.gem
  ```

## Authentication

We provide authentication credentials through an API client. Requests to the API are signed with a timestamp and are executed immediately.

1. [Create authentication credentials](https://techdocs.akamai.com/developer/docs/set-up-authentication-credentials).
   
2. Place your credentials in an EdgeGrid resource file, `.edgerc`, under a heading of `[default]` at your local home directory or the home directory of a web-server user.
   
   ```
    [default]
    client_secret = C113nt53KR3TN6N90yVuAgICxIRwsObLi0E67/N8eRN=
    host = akab-h05tnam3wl42son7nktnlnnx-kbob3i3v.luna.akamaiapis.net
    access_token = akab-acc35t0k3nodujqunph3w7hzp7-gtm6ij
    client_token = akab-c113ntt0k3n4qtari252bfxxbsl-yvsdj
    ```

3. Use your local `.edgerc` by providing the path to your resource file and credentials' section header in the `.setup_from_edgerc()` method.
   
   ```ruby
    http = Akamai::Edgegrid::HTTP.new(get_host(), 443)

    baseuri = URI('https://' + http.host)

    http.setup_from_edgerc(
      :filename => '~/.edgerc',
      :section => 'default'
    )
   ```
   
   Or hard code your credentials as variables in the `.setup_edgegrid()` method.

   ```ruby
    baseuri = URI('akab-h05tnam3wl42son7nktnlnnx-kbob3i3v.luna.akamaiapis.net/') # that's a `host` value from your `.edgerc` file

    http = Akamai::Edgegrid::HTTP.new(
        address=baseuri.host,
        port=baseuri.port
    )

    http.setup_edgegrid(
        :client_secret => 'C113nt53KR3TN6N90yVuAgICxIRwsObLi0E67/N8eRN=',
        :client_token => 'akab-c113ntt0k3n4qtari252bfxxbsl-yvsdj',
        :access_token => 'akab-acc35t0k3nodujqunph3w7hzp7-gtm6ij',
    )
   ```

## Use

To use the library, provide your credentials section header of your local `.edgerc` file, and the appropriate endpoint information.

```ruby
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

request = Net::HTTP::Get.new(URI.join(baseuri.to_s, 'identity-management/v3/user-profile').to_s)
request["Accept"] = "application/json"

response = http.request(request)
puts response.read_body
```

### Query string parameters

When entering query parameters, you can pass them in the url after a question mark ("?").

```ruby
request = Net::HTTP::Get.new(URI.join(baseuri.to_s, 'identity-management/v3/user-profile?authGrants=true&notifications=true&actions=true').to_s)

response = http.request(request)
puts response.read_body
```

Or you can pass them dynamically.

```ruby
baseuri = URI('https://' + http.host)
params = {
	:authGrants => true, 
	:notifications => true,
	:actions => true
}
baseuri.query = URI.encode_www_form(params)

request = Net::HTTP::Get.new URI.join(baseuri.to_s, 'identity-management/v3/user-profile').to_s

response = http.request(request)
puts response.read_body 
```

### Headers

Enter request headers using the `request[]` property. In the square brackets, specify the header name and then its value.

> **Note:** You don't need to include the `Content-Type` and `Content-Length` headers. The authentication layer adds these values.

```ruby
http = Akamai::Edgegrid::HTTP.new(get_host(), 443)

baseuri = URI('https://' + http.host)

http.setup_from_edgerc({:section => 'default'})

request = Net::HTTP::Get.new(URI.join(baseuri.to_s, 'identity-management/v3/user-profile').to_s)
request["Accept"] = "application/json"

response = http.request(request)
puts response.read_body
```

Another way to pass headers using the `initheader` argument:

```ruby
post_request = Net::HTTP::Get.new(
    URI.join(baseuri.to_s, 'identity-management/v3/user-profile').to_s,
    initheader = { 'Content-Type' => 'application/json' }
)
```

### Body data

Import `json` package and then provide the request body as an object in the `request.body` property.

```ruby
require 'akamai/edgegrid'
require "net/http"
require "uri"
require "json"


http = Akamai::Edgegrid::HTTP.new(get_host(), 443)
http.use_ssl = true

baseuri = URI('https://' + http.host)

http.setup_from_edgerc({:section => 'default'})

request = Net::HTTP::Put.new(URI.join(baseuri.to_s, 'identity-management/v3/user-profile/basic-info').to_s)
request.body = JSON.dump({
  "contactType": "Billing",
  "country": "USA",
  "firstName": "John",
  "lastName": "Smith",
  "phone": "3456788765",
  "preferredLanguage": "English",
  "sessionTimeOut": 30,
  "timeZone": "GMT",
})

response = http.request(request)
puts response.read_body
```

Another way to pass request body data.

```ruby
request.body = {
  "contactType": "Billing",
  "country": "USA",
  "firstName": "John",
  "lastName": "Smith",
  "phone": "3456788765",
  "preferredLanguage": "English",
  "sessionTimeOut": 30,
  "timeZone": "GMT",
}.to_json
```

## Reporting issues

To report an issue or make a suggestion, create a new [GitHub issue](https://github.com/akamai/AkamaiOPEN-edgegrid-ruby/issues).

## License

Copyright 2024 Akamai Technologies, Inc. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.