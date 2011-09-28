require "spec_helper"

describe Savon::Spec::Macros do
  include Savon::Spec::Macros

  describe "#savon" do
    it "returns a Savon::Spec::Mock instance" do
      savon.should be_a(Savon::Spec::Mock)
    end
  end

end
