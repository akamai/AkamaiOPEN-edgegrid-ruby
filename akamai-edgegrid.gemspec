Gem::Specification.new do |s|
  s.name        = 'akamai-edgegrid'
  s.version     = '1.0.7'
  s.date        = '2019-04-09'
  s.summary     = 'Akamai {OPEN} EdgeGrid Authenticator for net/http'
  s.description = 'Implements the Akamai {OPEN} EdgeGrid Authentication specified by https://developer.akamai.com/introduction/Client_Auth.html'
  s.files       = ["lib/akamai/edgegrid.rb"]
  s.homepage    = "https://github.com/akamai-open/AkamaiOPEN-edgegrid-ruby"
  s.license     = 'Apache'
  s.add_development_dependency 'simplecov', '~> 0.16'
  s.add_development_dependency 'minitest', '~> 5.11'
  s.add_runtime_dependency 'inifile', '~> 3.0'
  s.required_ruby_version = '>= 1.9'
end
