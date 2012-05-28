module Savon
  module Spec

    class ExpectationError < RuntimeError; end

    # = Savon::Spec::Mock
    #
    # Mocks Savon SOAP requests.
    class Mock

      # Hooks registered by Savon::Spec.
      HOOKS = [:spec_action, :spec_body, :spec_response]

      # Expects that a given +action+ should be called.
      def expects(expected)
        self.action = expected

        Savon.hooks.define(:spec_action, :soap_request) do |request|
          actual = request.soap.input[1]
          raise ExpectationError, "expected #{action.inspect} to be called, got: #{actual.inspect}" unless actual == action

          respond_with
        end

        self
      end

      # Accepts a SOAP +body+ to check if it was set. Also accepts a +block+
      # which receives the <tt>Savon::SOAP::Request</tt> to set up custom expectations.
      def with(body = nil, &block)
        Savon.hooks.define(:spec_body, :soap_request) do |request|
          if block
            block.call(request)
          else
            actual = request.soap.body
            raise ExpectationError, "expected #{body.inspect} to be sent, got: #{actual.inspect}" unless actual == body
          end

          respond_with
        end

        self
      end

      # Expects a given +response+ to be returned.
      def returns(response = nil)
        http = case response
          when Symbol then { :body => Fixture[action, response] }
          when Hash   then response
        end

        Savon.hooks.define(:spec_response, :soap_request) do |request|
          respond_with(http)
        end

        self
      end

      # Expects that the +action+ doesn't get called.
      def never
        Savon.hooks.reject!(:spec_action)

        Savon.hooks.define(:spec_never, :soap_request) do |request|
          actual = request.soap.input[1]
          raise ExpectationError, "expected #{action.inspect} never to be called, but it was!" if actual == action

          respond_with
        end

        self
      end

    private

      def action=(action)
        @action = action.is_a?(String) ? action.to_sym : action.to_s.lower_camelcase.to_sym
      end

      attr_reader :action

      def respond_with(http = {})
        defaults = { :code => 200, :headers => {}, :body => "" }
        http = defaults.merge(http)

        HTTPI::Response.new(http[:code], http[:headers], http[:body])
      end

    end
  end
end
