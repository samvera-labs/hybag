require 'spec_helper'
require File.join(DUMMY_PATH, "baggable_dummy")

describe Hybag::BagWriter do
  let(:bag) { BagIt::Bag.new('/tmp/bag') }
  subject {Hybag::BagWriter.new(@object,bag)}
  before(:each) do
    @object = BaggableDummy.new
    @object.descMetadata.content = File.open(File.join(FIXTURE_PATH,"example_datastream.nt"))
  end
  describe ".write!" do
    include FakeFS::SpecHelpers
    before(:each) do
      FileUtils.mkdir_p('/tmp/bag')
      subject.write!
    end
    it "should write tag files to disk" do
      bag.tag_files.last.should include('descMetadata.nt')
    end

  end

end