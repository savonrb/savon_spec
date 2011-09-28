module Savon
  module Spec

    # = Savon::Spec::Macros
    #
    # Include this module into your RSpec tests to mock Savon SOAP requests.
    module Macros

      def savon
        Mock.new
      end

    end
  end
end
