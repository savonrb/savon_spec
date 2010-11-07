require "spec_helper"

Savon.configure do |config|
  config.log = false
end

describe Savon::Spec::Mock do
  include Savon::Spec::Macros

  let :client do
    Savon::Client.new do
      wsdl.endpoint = "http://example.com"
      wsdl.namespace = "http://users.example.com"
    end
  end

  describe "#expects" do
    before { savon.expects(:get_user).returns }

    it "should set up HTTPI to mock POST requests for a given SOAP action" do
      client.request :get_user
    end

    it "should fail when no SOAP call was made" do
      expect { verify_mocks_for_rspec }.to raise_error(
        Mocha::ExpectationError,
        /expected exactly once, not yet invoked: HTTPI.post/
      )
      
      teardown_mocks_for_rspec
    end
  end

  describe "#expects and #with" do
    before { savon.expects(:get_user).with(:id => 1).returns }

    it "should expect Savon to send a given SOAP body" do
      client.request :get_user do
        soap.body = { :id => 1 }
      end
    end

    it "should fail when the SOAP body was not send" do
      client.request(:get_user)
      
      expect { verify_mocks_for_rspec }.to raise_error(
        Mocha::ExpectationError,
        /expected exactly once, not yet invoked: #<AnyInstance:Savon::SOAP::XML>.body=\(:id => 1\)/
      )
      
      teardown_mocks_for_rspec
    end
  end

  describe "#stubs" do
    before { savon.stubs(:get_user).returns }

    it "should set up HTTPI to stub POST requests for a given SOAP action" do
      client.request :get_user
    end

    it "should not complain about requests not being executed" do
      expect { verify_mocks_for_rspec }.to_not raise_error(Mocha::ExpectationError)
      teardown_mocks_for_rspec
    end
  end

  describe "#stubs and #with" do
    before { savon.stubs(:get_user).with(:id => 1).returns }

    it "should not expect Savon to send a given SOAP body" do
      client.request :get_user
    end
  end

  describe "#returns" do
    context "without arguments" do
      let(:response) { client.request :get_user }

      before { savon.expects(:get_user).returns }

      it "should return a response code of 200" do
        response.http.code.should == 200
      end

      it "should not return any response headers" do
        response.http.headers.should == {}
      end

      it "should return an empty response body" do
        response.http.body.should == ""
      end
    end

    context "with a String" do
      let(:response) { client.request :get_user }

      before { savon.expects(:get_user).returns("<soap>response</soap>") }

      it "should return a response code of 200" do
        response.http.code.should == 200
      end

      it "should not return any response headers" do
        response.http.headers.should == {}
      end

      it "should return the given response body" do
        response.http.body.should == "<soap>response</soap>"
      end
    end

    context "with a Symbol" do
      let(:response) { client.request :get_user }

      around do |example|
        Savon::Spec::Fixture.path = "spec/fixtures"
        savon.expects(:get_user).returns(:success)
        
        example.run
        
        Savon::Spec::Fixture.path = nil  # reset to default
      end

      it "should return a response code of 200" do
        response.http.code.should == 200
      end

      it "should not return any response headers" do
        response.http.headers.should == {}
      end

      it "should return the :success fixture for the :get_user action" do
        response.http.body.should == File.read("spec/fixtures/get_user/success.xml")
      end
    end

    context "with a Hash" do
      let(:response) { client.request :get_user }

      before do
        @hash = { :code => 201, :headers => { "Set-Cookie" => "ID=1; Max-Age=3600;" }, :body => "<with>cookie</with>" }
        savon.expects(:get_user).returns(@hash)
      end

      it "should return the given response code" do
        response.http.code.should == @hash[:code]
      end

      it "should return the given response headers" do
        response.http.headers.should == @hash[:headers]
      end

      it "should return the given response body" do
        response.http.body.should == @hash[:body]
      end
    end
  end

  describe "#with_soap_fault" do
    before { savon.expects(:get_user).raises_soap_fault.returns }

    it "should raise a SOAP fault" do
      expect { client.request :get_user }.to raise_error(Savon::SOAP::Fault)
    end

    it "should just act like there was a SOAP fault if raising errors was disabled" do
      Savon.raise_errors = false
      
      response = client.request :get_user
      response.should be_a_soap_fault
      
      Savon.raise_errors = true  # reset to default
    end
  end

end
