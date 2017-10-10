require 'coveralls'
Coveralls.wear!

require 'payoneer'
require 'awesome_print'

gemspec = Gem::Specification.find_by_name('payoneer')
Dir["#{gemspec.gem_dir}/spec/support/**/*.rb"].each { |f| require f }
