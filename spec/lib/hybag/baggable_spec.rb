require 'spec_helper'
require File.join(DUMMY_PATH, "baggable_dummy")
describe Hybag::Baggable do
  subject {BaggableDummy.new}
  it "should work" do
    expect(subject).not_to be_blank
  end
end