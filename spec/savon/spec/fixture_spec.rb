require "spec_helper"

describe Savon::Spec::Fixture do

  describe ".path" do
    it "should return a specified path" do
      Savon::Spec::Fixture.path = "/Users/rubiii/my_app/spec/fixtures"
      Savon::Spec::Fixture.path.should == "/Users/rubiii/my_app/spec/fixtures"
      
      Savon::Spec::Fixture.path = nil  # reset to default
    end

    it "should raise an ArgumentError if accessed before specified" do
      lambda { Savon::Spec::Fixture.path }.should raise_error(ArgumentError)
    end

    it "should default to spec/fixtures if used in a Rails app" do
      Rails = Class.new
      Rails.expects(:root).returns(Pathname.new("/Users/rubiii/another_app"))
      
      Savon::Spec::Fixture.path.should == "/Users/rubiii/another_app/spec/fixtures"
      
      Object.send(:remove_const, "Rails")
    end
  end

  describe ".load" do
    around do |example|
      Savon::Spec::Fixture.path = "spec/fixtures"
      example.run
      Savon::Spec::Fixture.path = nil  # reset to default
    end

    it "should return a fixture for the given arguments" do
      fixture = Savon::Spec::Fixture.load :get_user, :success
      fixture.should == File.read("spec/fixtures/get_user/success.xml")
    end

    it "should memoize the fixtures" do
      Savon::Spec::Fixture.load(:get_user, :success).
        should equal(Savon::Spec::Fixture.load(:get_user, :success))
    end
  end

end
