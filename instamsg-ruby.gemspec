# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'instamsg/ruby/version'

Gem::Specification.new do |spec|
  spec.name          = "instamsg-ruby"
  spec.version       = Instamsg::Ruby::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ["Instamsg"]
  spec.email         = ["support@sensegrow.com"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.summary       = %q{Instamsg api client.}
  spec.description   = %q{Wrapper for instamsg.io REST api}
  spec.homepage      = "http://github.com/instamsg/instamsg-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "httpclient", "~> 2.5"
  spec.add_dependency "jruby-openssl" if defined?(JRUBY_VERSION)

  spec.add_development_dependency "rspec", "~> 2.0"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "em-http-request", "~> 1.1.0"
  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end
