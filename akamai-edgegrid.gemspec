Gem::Specification.new do |s|
  s.name        = 'akamai-edgegrid'
  s.version     = '1.0.1'
  s.date        = '2014-05-14'
  s.summary     = 'Akamai {OPEN} EdgeGrid Authenticator for net/http'
  s.description = 'Implements the Akamai {OPEN} EdgeGrid Authentication specified by https://developer.akamai.com/stuff/Getting_Started_with_OPEN_APIs/Client_Auth.html'
  s.authors     = ["Jonathan Landis"]
  s.email       = 'jlandis@akamai.com'
  s.files       = ["lib/akamai/edgegrid.rb"]
  s.homepage    = "https://github.com/akamai-open/AkamaiOPEN-edgegrid-ruby"
  s.license     = 'Apache'
  s.add_development_dependency 'simplecov', '~> 0.7.1'
  s.required_ruby_version = '>= 1.9'
end
