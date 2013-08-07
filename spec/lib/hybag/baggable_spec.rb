require 'spec_helper'
require File.join(DUMMY_PATH, "baggable_dummy")


describe Hybag::Baggable do
  subject {@item}
  before(:each) do
    @item = BaggableDummy.new(:pid => "filler")
    @item.descMetadata.content = File.open(File.join(FIXTURE_PATH,"example_datastream.nt")).read
    content_file = File.open(File.join(FIXTURE_PATH,"hydra.png"))
    @item.add_file_datastream(content_file, :dsid => "content", :mimeType => "image/png")
    @item.stub(:persisted?).and_return(true)
    # Stub Rails root
    rails = double("Rails")
    Rails = rails unless defined?(Rails)
    Rails.stub(:root).and_return(Pathname.new('/test'))
  end
  before(:all) do
  end
  describe ".generate_bag_path" do
    context "when given a path name" do
      it "should return the Rails Root appended with the bag_path_namespace, path, and then namespace" do
        subject.send(:generate_bag_path, 'testing').should == File.join("/test",subject.send(:bag_path_namespace),"testing","filler")
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
        @bag = @item.write_bag('/tmp/bag')
      end
      it "should write tag files to disk" do
        # TODO: stub out a rels-ext to make sure this happens.
        #@bag.tag_files.should include(File.join(@bag.bag_dir, 'fedora', 'RELS-EXT.rdf'))
        @bag.tag_files.should include(File.join(@bag.bag_dir, 'descMetadata.nt'))
      end
      it "should write content files to disk" do
        @bag.bag_files[0].should include('content.png')
      end
      it "should update existing bags" do
        @item.title = "Star Wars: A New Title"
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
      it "should create deep subdirectories" do
        bag = @item.write_bag('deep/newBagDir')
        File.directory?(bag.bag_dir).should be_true
        bag.bag_dir.should include('deep/newBagDir')
      end
      it "should delete bags" do
        File.directory?(@bag.bag_dir).should be_true
        @item.delete_bag
        File.directory?(@bag.bag_dir).should be_false
      end


      context "when the item is unsaved" do
        before(:each) do
          @item.stub(:persisted?).and_return(false)
        end
        it "should error" do
          expect{@item.write_bag}.to raise_error
        end
      end


    end
  end
end