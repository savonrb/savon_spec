require "savon/spec/mock"

module Savon
  module Spec

    # = Savon::Spec::Macros
    #
    # Include this module into your RSpec tests to mock/stub Savon SOAP requests.
    module Macros

      def savon
        Savon::Spec::Mock.new
      end

    end
  end
end
