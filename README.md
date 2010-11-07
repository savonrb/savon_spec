Savon::Spec
===========

Savon testing library

Installation
------------

Savon::Spec is available through [Rubygems](http://rubygems.org/gems/savon_spec) and can be installed via:

    $ gem install savon_spec

Dependencies
------------

Currently, the dependencies are very strict. Savon::Spec is meant to be used with:

* [Savon](http://rubygems.org/gems/savon) ~> 0.8.0.beta.3
* [RSpec](http://rubygems.org/gems/rspec) ~> 2.0.0
* [Mocha](http://rubygems.org/gems/mocha) ~> 0.9.8

Note to self: the required versions for RSpec and Mocha could probably be lower.

Getting started
---------------

### Macros

Include the `Savon::Spec::Macros` module:

    RSpec.configure do |config|
      config.include Savon::Spec::Macros
    end

### Mock

By including the macros, you have access to the `savon` method in your specs. It returns a `Savon::Spec::Mock` instance to set up your expectations. It's based on Mocha and comes with similiar methods:

    #expects(soap_action)       # mocks SOAP request to a given SOAP action
    #stubs(soap_action)         # stubs SOAP requests to a given SOAP action
    #with(soap_body)            # expects Savon to send a given SOAP body
    #raises_soap_fault          # raises or acts like there was a SOAP fault
    #returns(response)          # returns the given response

### Fixtures

Savon::Spec works best with SOAP response fixtures (simple XML files) and a conventional folder structure:

    ~ spec
      ~ fixtures
        ~ get_user
          - single_user.xml
          - multiple_users.xml
      + models
      + controllers
      + helpers
      + views

When used inside a Rails 3 application, Savon::Spec uses the command `Rails.root.join("spec", "fixtures")` to locate your fixture directory. In any other case, you have to manually set the fixture path via:

    Savon::Spec::Fixture.path = File.expand_path("../fixtures", __FILE__)

The directories inside the fixture directory should map to SOAP actions and the XML fixtures inside those directories should describe the SOAP response. Please take a look at the following examples to better understand this convention.

An example
----------

user.rb

    class User

      def self.all
        response = client.request :get_all_users
        response.to_hash.map { |user_hash| new user_hash }
      end

      def self.find(user_id)
        response = client.request :get_user do
          soap.body = { :id => user_id }
        end
        
        new response.to_hash
      end

    end

user_spec.rb

    describe User do

      describe ".all" do
        before do
          savon.expects(:get_all_users).returns(:multiple_users)
        end

        it "should return an Array of Users" do
          User.all.each { |user| user.should be_a(User) }
        end

        it "should return exactly 7 Users" do
          User.all.should have(7).items
        end
      end

      describe ".find" do
        before do
          savon.expects(:get_user).with(:id => 1).returns(:single_user)
        end

        it "should return a User for a given :id" do
          User.find(1).should be_a(User)
        end
      end

    end
