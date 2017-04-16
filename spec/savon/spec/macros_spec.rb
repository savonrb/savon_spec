require "spec_helper"

describe Savon::Spec::Macros do
  include Savon::Spec::Macros

  describe "#savon" do
    it "returns a Savon::Spec::Mock instance" do
      expect(savon).to be_kind_of(Savon::Spec::Mock)
    end
  end

end
