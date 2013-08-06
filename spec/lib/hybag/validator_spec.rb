require 'spec_helper'
require File.join(DUMMY_PATH, "baggable_dummy")

describe Hybag::Validator do
  include FakeFS::SpecHelpers
  let(:dummy) {BaggableDummy.new}
  subject{Hybag::Validator.new(dummy, '/tmp/bag')}
  describe "validations" do
    context "when the given path exists" do
      before(:each) do
        FileUtils.mkdir_p '/tmp/bag'
      end
      it "should be invalid" do
        expect(subject).not_to be_valid
      end
    end
  end
end