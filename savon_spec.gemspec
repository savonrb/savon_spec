lib = File.expand_path("../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)

require "savon/spec/version"

Gem::Specification.new do |s|
  s.name = "savon_spec"
  s.version = Savon::Spec::VERSION
  s.authors = "Daniel Harrington"
  s.email = "me@rubiii.com"
  s.homepage = "http://github.com/rubiii/#{s.name}"
  s.summary = "Savon testing library"
  s.description = "Test helpers for the Savon SOAP library."

  s.rubyforge_project = s.name

  s.add_dependency "savon", ">= 0.8.0"
  s.add_dependency "rspec", ">= 2.0.0"
  s.add_dependency "mocha", ">= 0.9.8"

  s.add_development_dependency "httpclient", "~> 2.1.5"
  s.add_development_dependency "webmock", "~> 1.4.0"

  s.files = `git ls-files`.split("\n")
  s.require_path = "lib"
end
