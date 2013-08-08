require 'spec_helper'
require 'open-uri'
require 'pry'
require File.join(DUMMY_PATH, "baggable_dummy")

# Override Kernel.open
module ::Kernel
  private

  alias :original_open :open
  def open(name, *rest, &block)
    if name =~ /\|.*/ then
      original_open(name, *rest, &block)
    else
      FakeFS::File.open(name, *rest, &block)
    end
  end
  module_function :open
end

describe Hybag::Ingester do
  before(:each) do
    @item = BaggableDummy.new(:pid => "filler")
    @item.descMetadata.content = File.open(File.join(FIXTURE_PATH,"example_datastream.nt")).read
    content_file = File.open(File.join(FIXTURE_PATH,"hydra.png"))
    @item.add_file_datastream(content_file, :dsid => "content", :mimeType => "image/png")
    @item.rels_ext.content = File.open(File.join(FIXTURE_PATH,"rels.rdf")).read
    @item.load_relationships
    @item.stub(:persisted?).and_return(true)
    # Stub Rails root
    rails = double("Rails")
    Rails = rails unless defined?(Rails)
    Rails.stub(:root).and_return(Pathname.new('/test'))
  end
  let(:item) {@item}
  let(:bag) {item.write_bag}
  subject {Hybag::Ingester.new(bag)}
  describe "functionality" do
    include FakeFS::SpecHelpers
    describe ".model_name" do
      context "when there is a rels" do
        it "should return the model name stored by the bag in rels" do
          subject.send(:model_name).should == "BaggableDummy"
        end
      end
      context "when there is no rels" do
        context "when there is a hybag.yml" do
          before(:each) do
            FileUtils.rm(subject.send(:fedora_rels), :force => true)
            # Add the hybag.yml from fixture
            FakeFS.deactivate!
            hybag_content = File.read(File.join(FIXTURE_PATH,"hybag.yml"))
            FakeFS.activate!
            File.open(File.join(bag.bag_dir,"hybag.yml"),'w') {|f| f.puts hybag_content}
          end
          it "should pull the data out of hybag.yml" do
            subject.send(:model_name).should == "TestModel"
          end
        end
      end
      context "when there is a rels and a hybag.yml" do
        before(:each) do
          # Add the hybag.yml from fixture
          FakeFS.deactivate!
          hybag_content = File.read(File.join(FIXTURE_PATH,"hybag.yml"))
          FakeFS.activate!
          File.open(File.join(bag.bag_dir,"hybag.yml"),'w') {|f| f.puts hybag_content}
        end
        it "should prioritize the rels" do
          subject.send(:model_name).should == "BaggableDummy"
        end
      end
    end
    describe ".ingest!" do
      context "when there is no discoverable model" do
        before(:each) do
          subject.stub(:model_name).and_return(nil)
        end
        it "should raise an error" do
          expect{subject.ingest!}.to raise_error("Unable to determine model from bag")
        end
      end
      context "when there is a model" do
        it "should return an instance of that model" do
          expect(subject.ingest!).to be_kind_of(BaggableDummy)
        end
        context "and that model is not defined" do
          before(:each) do
            subject.stub(:model_name).and_return("Blabla")
          end
          it "should raise an error" do
            expect{subject.ingest!}.to raise_error
          end
        end
      end
    end
  end
end
