require "spec_helper"

describe Savon::Spec::Mock do
  include Savon::Spec::Macros

  let(:client) do
    Savon::Client.new do
      wsdl.endpoint = "http://example.com"
      wsdl.namespace = "http://users.example.com"
    end
  end

  describe "#expects" do

    before do
      savon.expects(:get_user)
    end

    it "does not execute a POST request (verified via WebMock)" do
      client.request(:get_user)
    end

    it "fails when a different SOAP action was called" do
      expect { client.request(:get_user_by_id) }.to raise_error(
        Savon::Spec::ExpectationError,
        "expected :getUser to be called, got: :getUserById"
      )
    end

  end

  describe "#with" do

    context "a Hash" do

      before do
        savon.expects(:get_user).with(:id => 1)
      end

      it "expects Savon to send a specific SOAP body" do
        client.request :get_user, :body => { :id => 1 }
      end

      it "fails when the SOAP body was not set" do
        expect { client.request(:get_user) }.to raise_error(
          Savon::Spec::ExpectationError,
          "expected {:id=>1} to be sent, got: nil"
        )
      end

      it "fails when the SOAP body did not match the expected value" do
        expect { client.request :get_user, :body => { :id => 2 } }.to raise_error(
          Savon::Spec::ExpectationError,
          "expected {:id=>1} to be sent, got: {:id=>2}"
        )
      end

    end

    context "a block" do

      before do
        savon.expects(:get_user).with do |request|
          request.soap.body.should include(:id)
        end
      end

      it "works with a custom expectation" do
        client.request :get_user, :body => { :id => 1 }
      end

      it "fails when the expectation was not met" do
        begin
          client.request :get_user, :body => { :name => "Dr. Who" }
        rescue Spec::Expectations::ExpectationNotMetError => e
          e.message.should =~ /expected \{:name=>"Dr. Who"\} to include :id/
        end
      end

    end

  end

  describe "#never" do

    before do
      savon.expects(:noop).never
    end

    it "expects Savon to never call a specific SOAP action" do
      expect { client.request(:noop) }.to raise_error(
        Savon::Spec::ExpectationError,
        "expected :noop never to be called, but it was!"
      )
    end

  end

  describe "#returns" do

    context "without arguments" do

      let(:response) do
        client.request(:get_user)
      end

      before do
        savon.expects(:get_user)
      end

      it "returns a response code of 200" do
        response.http.code.should == 200
      end

      it "does not return any response headers" do
        response.http.headers.should == {}
      end

      it "returns an empty response body" do
        response.http.body.should == ""
      end

    end

    context "with a Symbol" do

      let(:response) do
        client.request(:get_user)
      end

      around do |example|
        Savon::Spec::Fixture.path = "spec/fixtures"
        savon.expects(:get_user).returns(:success)

        example.run

        Savon::Spec::Fixture.path = nil  # reset to default
      end

      it "returns a response code of 200" do
        response.http.code.should == 200
      end

      it "does not return any response headers" do
        response.http.headers.should == {}
      end

      it "returns the :success fixture for the :get_user action" do
        response.http.body.should == File.read("spec/fixtures/get_user/success.xml")
      end

    end

    context "with a Hash" do

      let(:response) do
        client.request(:get_user)
      end

      let(:http) do
        { :code => 201, :headers => { "Set-Cookie" => "ID=1; Max-Age=3600;" }, :body => "<with>cookie</with>" }
      end

      before do
        savon.expects(:get_user).returns(http)
      end

      it "returns the given response code" do
        response.http.code.should == http[:code]
      end

      it "returns the given response headers" do
        response.http.headers.should == http[:headers]
      end

      it "returns the given response body" do
        response.http.body.should == http[:body]
      end

    end

  end

end
