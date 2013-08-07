require 'spec_helper'
require File.join(DUMMY_PATH, "baggable_dummy")


describe Hybag::Baggable do
  subject {BaggableDummy.new}
  let(:bag) { BagIt::Bag.new('/tmp/bag') }
  before(:each) do
    @item = BaggableDummy.new
    @item.descMetadata.content = File.open(File.join(FIXTURE_PATH,"example_datastream.nt"))
  end
  describe ".write_bag" do
    include FakeFS::SpecHelpers
    describe "validations" do
      context "when not given a path" do
        it "should error" do
          expect{subject.write_bag}.to raise_error
        end
      end
      context "when given a path that does not exist" do
        it "should not error" do
          expect{subject.write_bag('/tmp/bag')}.not_to raise_error
        end
      end
    end
    describe "writing" do
      before(:each) do
        subject.write_bag('/tmp/bag')
      end
      it "should write tag files to disk" do
        bag.tag_files.last.should include('descMetadata.nt')
      end
      it "should update existing bags" do
        @item.title = "Star Wars: A New Title"
        expect {@item.write_bag('/tmp/bag')}.to_not raise_error
        bag = @item.write_bag('/tmp/bag')
        File.open(File.join(bag.bag_dir, 'descMetadata.nt')).read.should include("Star Wars: A New Title")
      end
    end
  end
end