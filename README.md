edgegrid-ruby
=============
[Akamai {OPEN} EdgeGrid Authentication] for ruby ([net/http])

[Akamai {OPEN} EdgeGrid Authentication]: https://developer.akamai.com/introduction/Client_Auth.html
[net/http]: http://www.ruby-doc.org/stdlib-1.9.3/libdoc/net/http/rdoc/Net/HTTP.html

This library implements the Akamai {OPEN} EdgeGrid Authentication scheme for
the ruby net/http library.

For more information visit the [Akamai {OPEN} Developer Community](https://developer.akamai.com).

Installation
------------

This library requires ruby v1.9 or later.  To easily install we
recommend using [rbenv](https://github.com/sstephenson/rbenv), [rubygems](http://rubygems.org/) and [bundler](http://bundler.io/)

* Install from rubygems

```bash
gem install akamai-edgegrid
```

* Install from sources (we assume you already have rbenv going)

```bash
rbenv local 1.9.3-p545
gem install bundler
bundle install
rake test
gem build akamai-edgegrid.gemspec
gem install akamai-edgegrid-1.0.gem
```

Usage
-----

```ruby
require 'akamai/edgegrid'
require 'net/http'
require 'uri'

baseuri = URI('https://akaa-xxxxxxxxx.luna.akamaiapis.net/')

http = Akamai::Edgegrid::HTTP.new(
    address=baseuri.host,
    port=baseuri.port
)

http.setup_edgegrid(
    :client_token => 'ccccccccccccccc',
    :client_secret => 'sssssssssssssssssssssss',
    :access_token => 'aaaaaaaaaaaaaaaaaaaa',
    :max_body => 128 * 1024
)

# example of simple GET request
request = Net::HTTP::Get.new URI.join(baseuri.to_s, '/diagnostic-tools/v1/locations').to_s
response = http.request(request)
puts response.body

# exmaple of POST request with a json formatted request body

require 'json'
account_id = 'account-id-goes-here'
start_time = Time.now.to_i * 1000
end_time = start_time + 86400000

post_request = Net::HTTP::Post.new(
    URI.join(baseuri.to_s, "/events/v2/#{account_id}/events").to_s,
    initheader = { 'Content-Type' => 'application/json' }
)

post_request.body = {
    "name" => "A test event",
    "start" => start_time,
    "end" => end_time
}.to_json

post_response = http.request(post_request)
puts post_response.body
```

1. First initialize a new EdgegridHTTP object.  This is a subclass of
   Net::HTTP and thus has all methods from that class avaialble for use.

2. Next initialize the configuration of Edgegrid via the `setup_edgegrid`
   method.  You must pass the :client_token, and :client_secret from the
   "Credentials" screen of the Manage APIs UI and the :access_token
   from the "Authorizations" section of the Manage APIs UI.

3. Finally, use Net::HTTP methods as usual.  EdgegridHTTP will add 
   the property Authentication header to sign your http messages.

Author
------

Jonathan Landis <jlandis@akamai.com>

License
-------

Copyright 2014 Akamai Technologies, Inc.  All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
