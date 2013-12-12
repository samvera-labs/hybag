require 'spec_helper'
require 'open-uri'
require 'pry'
require File.join(DUMMY_PATH, "baggable_dummy")

describe Hybag do
  describe ".ingest" do
    include FakeFS::SpecHelpers
    it "should call Hybag::Ingester.ingest" do
      Hybag::Ingester.any_instance.should_receive(:ingest).and_return("bla")
      Hybag.ingest("empty")
    end
    it "should make a bag out of a directory" do
      BagIt::Bag.should_receive(:new).with("/bag/directory")
      Hybag::Ingester.any_instance.should_receive(:ingest).and_return("bla")
      Hybag.ingest("/bag/directory")
    end
    context "full test" do
      before(:each) do
        FileUtils.mkdir_p("/bag/directory")
        FakeFS.deactivate!
        @item = BaggableDummy.new(:pid => '1')
        @item.descMetadata.content = File.open(File.join(FIXTURE_PATH,"example_datastream.nt")).read.strip
        content_file = File.open(File.join(FIXTURE_PATH,"hydra.png"))
        @item.add_file_datastream(content_file, :dsid => "content", :mimeType => "image/png")
        @item.rels_ext.content = File.open(File.join(FIXTURE_PATH,"rels.rdf")).read
        @item.load_relationships
        @item.stub(:persisted?).and_return(true)
        # Stub Rails root
        rails = double("Rails")
        Rails = rails unless defined?(Rails)
        Rails.stub(:root).and_return(Pathname.new('/'))
        # Stub ActiveFedora assign_pid
        ActiveFedora::Base.stub(:assign_pid).and_return("new_pid")
        @item.stub(:bag_path_namespace).and_return(File.join("bag","directory"))
        FakeFS.activate!
        @bag = @item.write_bag
      end
      it "should return objects" do
        objects = Hybag.ingest("/bag/directory")
        expect(objects.length).to eq 1
        expect(objects.first).to be_kind_of(ActiveFedora::Base)
      end
    end
    context "when given a directory of bags" do
      before(:each) do
        Hybag.should_receive(:bulk_directory?).and_return(true)
      end
      it "should not call Ingester" do
        Hybag::Ingester.any_instance.should_not_receive(:ingest)
        Hybag.ingest("/bag/directory")
      end
      it "should call Bulk Ingester" do
        Hybag::BulkIngester.should_receive(:new).with("/bag/directory").and_return([])
        Hybag.ingest("/bag/directory")
      end
    end
    it "should allow the ingester to be configurable" do
      ingesting = nil
      Hybag::Ingester.any_instance.should_receive(:ingest).and_return("bla")
      Hybag.ingest("empty") do |ingester|
        ingester.model_name = "TestModel"
        ingesting = ingester
      end
      expect(ingesting.model_name).to eq "TestModel"
    end
  end
end
