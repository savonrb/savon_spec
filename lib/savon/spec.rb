require "savon"
require "rspec"

module Savon
  module Spec

    autoload :Macros,  "savon/spec/macros"
    autoload :Mock,    "savon/spec/mock"
    autoload :Fixture, "savon/spec/fixture"

  end
end

RSpec.configure do |config|
  config.after { Savon.config.hooks.reject(Savon::Spec::Mock::HOOKS) }
end
