require "savon/spec/fixture"

module Savon
  module Spec

    # = Savon::Spec::Mock
    #
    # Mocks/stubs SOAP requests executed by Savon.
    class Mock

      # Mocks SOAP requests to a given <tt>soap_action</tt>.
      def expects(soap_action)
        setup :expects, soap_action
        self
      end

      # Stubs SOAP requests to a given <tt>soap_action</tt>.
      def stubs(soap_action)
        setup :stubs, soap_action
        self
      end

      # Expects a given SOAP body Hash to be used.
      def with(soap_body)
        Savon::SOAP::XML.any_instance.expects(:body=).with(soap_body) if mock_method == :expects
        self
      end

      def never
        httpi_mock.never
        self
      end

      # Sets up HTTPI to return a given +response+.
      def returns(response = nil)
        http = { :code => 200, :headers => {}, :body => "" }
        
        case response
          when Symbol   then http[:body] = Fixture[soap_action, response]
          when Hash     then http.merge! response
          when String   then http[:body] = response
        end
        
        httpi_mock.returns HTTPI::Response.new(http[:code], http[:headers], http[:body])
        self
      end

      # Sets up Savon to respond like there was a SOAP fault.
      def raises_soap_fault
        Savon::SOAP::Response.any_instance.expects(:soap_fault?).returns(true)
        self
      end

    private

      def setup(mock_method, soap_action)
        self.mock_method = mock_method
        self.soap_action = soap_action
        self.httpi_mock = new_httpi_mock
      end

      attr_accessor :mock_method

      def soap_action=(soap_action)
        @soap_action = soap_action.kind_of?(Symbol) ? soap_action.to_s.lower_camelcase : soap_action
      end

      attr_reader :soap_action

      def new_httpi_mock
        HTTPI.send(mock_method, :post).with { |http| http.body.include? soap_action }
      end

      attr_accessor :httpi_mock

    end
  end
end
