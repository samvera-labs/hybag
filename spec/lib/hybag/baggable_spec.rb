require 'spec_helper'
require File.join(DUMMY_PATH, "baggable_dummy")


describe Hybag::Baggable do
  subject {@item}
  before(:each) do
    @item = BaggableDummy.new(:pid => "filler")
    @item.descMetadata.content = File.open(File.join(FIXTURE_PATH,"example_datastream.nt")).read
    @item.content.content = File.open(File.join(FIXTURE_PATH,"hydra.png")).read
    # Stub Rails root
    rails = double("Rails")
    Rails = rails unless defined?(Rails)
    Rails.stub(:root).and_return(Pathname.new('/test'))
  end
  before(:all) do
  end
  describe ".bag_path", :focus => true do
    context "when given a path name" do
      it "should return the Rails Root appended with the bag_path_namespace, path, and then namespace" do
        subject.send(:bag_path, 'testing').should == File.join("/test",subject.send(:bag_path_namespace),"testing","filler")
      end
    end
  end
  describe ".write_bag" do
    include FakeFS::SpecHelpers
    describe "validations" do
      context "when not given a path" do
        it "should not error" do
          expect{subject.write_bag}.not_to raise_error
        end
      end
      context "when given a path that does not exist" do
        it "should not error" do
          expect{subject.write_bag('/tmp/bag')}.not_to raise_error
        end
      end
    end
    describe "writing" do
      let(:bag) {@bag}
      before(:each) do
        @bag = subject.write_bag
      end
      it "should write tag files to disk" do
        expect(bag.tag_files.select{|x| x.include? 'descMetadata.nt'}.length).to eq 1
      end
      it "should update existing bags" do
        @item.title = "Star Wars: A New Title"
        expect {@item.write_bag('/tmp/bag')}.to_not raise_error
        bag = @item.write_bag('/tmp/bag')
        File.open(File.join(bag.bag_dir, 'descMetadata.nt')).read.should include("Star Wars: A New Title")
      end
      it "should give back a valid bag" do
        expect(bag).to be_valid
      end
      it "should accept subdirectories" do
        bag = @item.write_bag('newBagDir')
        File.directory?(bag.bag_dir).should be_true
        bag.bag_dir.should include('newBagDir')
      end


    end
  end
end