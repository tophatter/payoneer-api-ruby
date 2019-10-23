# To publish the next version:
# gem build payoneer-client.gemspec
# gem push payoneer-client-{VERSION}.gem
Gem::Specification.new do |s|
  s.name        = 'payoneer-client'
  s.version     = '0.7.0'
  s.platform    = Gem::Platform::RUBY
  s.licenses    = ['MIT']
  s.authors     = ['Chris Estreich', 'Todd Eichel']
  s.email       = ['chris@tophatter.com', 'todd@tophatter.com']
  s.homepage    = 'https://github.com/tophatter/payoneer-api-ruby'
  s.summary     = 'Payoneer SDK for ruby.'
  s.description = 'Payoneer SDK for ruby.'

  s.extra_rdoc_files = ['README.md']

  s.add_dependency 'activesupport', '~> 4.2'
  s.add_dependency 'rest-client'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
end
