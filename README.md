Savon::Spec [![Build Status](https://secure.travis-ci.org/rubiii/savon_spec.png)](http://travis-ci.org/rubiii/savon_spec)
===========

Savon v1 Rspec Helpers

Deprecated
==========

Starting in Savon v2, [spec helpers are included in Savon itself](http://savonrb.com/version2/testing.html). This gem is only helpful if you're using Savon v1. It is highly recommended to use Savon v2 with the `Savon::SpecHelper` module for new projects.


Installation
------------

Savon::Spec is available through [Rubygems](http://rubygems.org/gems/savon_spec) and can be installed via:

```
$ gem install savon_spec
```


Expects
-------

Include the `Savon::Spec::Macros` module into your specs:

``` ruby
RSpec.configure do |config|
  config.include Savon::Spec::Macros
end
```

By including the module you get a `savon` method to mock SOAP requests. Here's a very simple example:

```  ruby
let(:client) do
  Savon::Client.new do
    wsdl.endpoint = "http://example.com"
    wsdl.namespace = "http://users.example.com"
  end
end

before do
  savon.expects(:get_user)
end

it "mocks a SOAP request" do
  client.request(:get_user)
end
```

This sets up an expectation for Savon to call the `:get_user` action and the specs should pass without errors.
Savon::Spec does not execute a POST request to your service, but uses [Savon hooks](http://savonrb.com/#hook_into_the_system) to return a fake response:

``` ruby
{ :code => 200, :headers => {}, :body => "" }
```

To further isolate your specs, I'd suggest setting up [FakeWeb](http://rubygems.org/gems/fakeweb) to disallow any HTTP requests.  


With
----

Mocking SOAP requests is fine, but what you really need to do is verify whether you're sending the right
parameters to your service.

```  ruby
before do
  savon.expects(:get_user).with(:id => 1)
end

it "mocks a SOAP request" do
  client.request(:get_user) do
    soap.body = { :id => 1 }
  end
end
```

This checks whether Savon uses the SOAP body Hash you expected and raises a `Savon::Spec::ExpectationError` if it doesn't.

```
Failure/Error: client.request :get_user, :body => { :name => "Dr. Who" }
Savon::Spec::ExpectationError:
  expected { :id => 1 } to be sent, got: { :name => "Dr. Who" }
```

You can also pass a block to the `#with` method and receive the `Savon::SOAP::Request` before the POST request is executed.  
Here's an example of a custom expectation:

``` ruby
savon.expects(:get_user).with do |request|
  expect(request.soap.body).to include(:id)
end
```


Returns
-------

Instead of the default fake response, you can return a custom HTTP response by passing a Hash to the `#returns` method.  
If you leave out any of these values, Savon::Spec will add the default values for you.

``` ruby
savon.expects(:get_user).returns(:code => 500, :headers => {}, :body => "save the unicorns")
```

Savon::Spec also works with SOAP response fixtures (simple XML files) and a conventional folder structure:

```
~ spec
  ~ fixtures
    ~ get_user
      - single_user.xml
      - multiple_users.xml
  + models
  + controllers
  + helpers
  + views
```

When used inside a Rails 3 application, Savon::Spec uses `Rails.root.join("spec", "fixtures")` to locate your fixture directory.  
In any other case, you have to manually set the fixture path via:

``` ruby
Savon::Spec::Fixture.path = File.expand_path("../fixtures", __FILE__)
```

Directory names inside the fixtures directory map to SOAP actions and contain actual SOAP responses from your service(s).  
You can use one of those fixtures for the HTTP response body like in the following example:

``` ruby
savon.expects(:get_user).with(:id => 1).returns(:single_user)
```

As you can see, Savon::Spec uses the name of your SOAP action and the Symbol passed to the `#returns` method to navigate inside  
your fixtures directory and load the requested XML files.


Never
-----

Savon::Spec can also verify that a certain SOAP request was not executed:

``` ruby
savon.expects(:get_user).never
```


RSpec
-----

This library is optimized to work with RSpec, but it could be tweaked to work with any other testing library.  
Savon::Spec installs an after filter to clear out its Savon hooks after each example.

