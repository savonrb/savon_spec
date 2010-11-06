require "savon"
require "rspec"
require "mocha"

RSpec.configure do |config|
  config.mock_with :mocha
end

require "savon/spec/version"
require "savon/spec/macros"
