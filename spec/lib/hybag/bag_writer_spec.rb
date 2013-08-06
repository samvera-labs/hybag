require 'spec_helper'
require File.join(DUMMY_PATH, "baggable_dummy")

describe Hybag::BagWriter do
  include FakeFS::SpecHelpers
  let(:object) do
    dummy = BaggableDummy.new
    dummy.descMetadata.content = File.open(File.join(FIXTURE_PATH,"example_datastream.nt")).read
    dummy
  end
  let(:bag) { Bagit::Bag.new('/tmp/bag') }
  subject {Hybag::BagWriter.new(object,bag)}
  describe ".write!" do
    it "should write" do
      puts object.descMetadata.identifier.content
    end
  end

end