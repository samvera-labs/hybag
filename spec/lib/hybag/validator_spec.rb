require 'spec_helper'
require File.join(DUMMY_PATH, "baggable_dummy")

describe Hybag::Validator do
  include FakeFS::SpecHelpers
  let(:dummy) do
    d = BaggableDummy.new
    d.stub(:persisted?).and_return(true)
    return d
  end
  subject{Hybag::Validator.new(dummy)}
  describe "validations" do
    context "when the given path exists" do
      before(:each) do
        FileUtils.mkdir_p '/tmp/bag'
      end
      it "should be valid" do
        expect(subject).to be_valid
      end
    end
    context "when the given path doesn't exist" do
      it "should be valid" do
        expect(subject).to be_valid
      end
    end
    context "when the bag isn't baggable" do
      before(:each) do
        dummy.stub(:baggable?).and_return(false)
      end
      it "should not be valid" do
        expect(subject).not_to be_valid
      end
    end
  end
  describe ".validate!" do
    context "when the subject is valid" do
      it "should not raise an error" do
        expect{subject.validate!}.not_to raise_error
      end
    end
    context "when the subject is invalid" do
      before(:each) do
        dummy.stub(:baggable?).and_return(false)
      end
      it "should raise an error" do
        expect{subject.validate!}.to raise_error(Hybag::InvalidBaggable)
      end
    end
  end
end