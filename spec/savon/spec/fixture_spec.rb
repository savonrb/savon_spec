require "spec_helper"

describe Savon::Spec::Fixture do

  describe ".path" do

    it "returns a specified path" do
      Savon::Spec::Fixture.path = "/Users/dr_who/some_app/spec/fixtures"
      expect(Savon::Spec::Fixture.path).to eq("/Users/dr_who/some_app/spec/fixtures")

      Savon::Spec::Fixture.path = nil  # reset to default
    end

    it "raises an ArgumentError when accessed before specified" do
      expect { Savon::Spec::Fixture.path }.to raise_error(ArgumentError)
    end

    it "defaults to spec/fixtures when used in a Rails app" do
      Rails = Class.new do
        def self.root
          Pathname.new("/Users/dr_who/another_app")
        end
      end

      expect(Savon::Spec::Fixture.path).to eq("/Users/dr_who/another_app/spec/fixtures")

      Object.send(:remove_const, "Rails")
    end

  end

  describe ".load" do

    around do |example|
      Savon::Spec::Fixture.path = "spec/fixtures"
      example.run
      Savon::Spec::Fixture.path = nil  # reset to default
    end

    it "returns a fixture for the given arguments" do
      fixture = Savon::Spec::Fixture.load :get_user, :success
      expect(fixture).to eq(File.read("spec/fixtures/get_user/success.xml"))
    end

    it "memoizes the fixtures" do
      expect(Savon::Spec::Fixture.load(:get_user, :success)).to be(Savon::Spec::Fixture.load(:get_user, :success))
    end

  end

end
