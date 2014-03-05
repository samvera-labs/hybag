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
    @item.descMetadata.content = File.open(File.join(FIXTURE_PATH,"example_datastream.nt")).read.strip
    content_file = File.open(File.join(FIXTURE_PATH,"hydra.png"))
    @item.add_file_datastream(content_file, :dsid => "content", :mimeType => "image/png")
    @item.rels_ext.content = File.open(File.join(FIXTURE_PATH,"rels.rdf")).read
    @item.load_relationships
    @item.stub(:persisted?).and_return(true)
    # Stub Rails root
    rails = double("Rails")
    Rails = rails unless defined?(Rails)
    Rails.stub(:root).and_return(Pathname.new('/test'))
    # Stub ActiveFedora assign_pid
    ActiveFedora::Base.stub(:assign_pid).and_return("new_filler")
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
        context "but a model name is explicitly configured" do
          before(:each) do
            subject.model_name = "TestModel"
          end
          it "should have a configured model name" do
            expect(subject.send(:model_name)).to eq "TestModel"
          end
        end
      end
    end
    describe ".ingest" do
      context "when there is no discoverable model" do
        before(:each) do
          subject.stub(:model_name).and_return(nil)
        end
        it "should raise an error" do
          expect{subject.ingest}.to raise_error(Hybag::UndiscoverableModelName)
        end
      end
      context "when there is a model" do
        it "should return an instance of that model" do
          expect(subject.ingest).to be_kind_of(BaggableDummy)
        end
        it "should assign that model a pid" do
          expect((subject.ingest).pid).to eq "new_filler"
        end
        context "and that model is not defined" do
          before(:each) do
            subject.stub(:model_name).and_return("Blabla")
          end
          it "should raise an error" do
            expect{subject.ingest}.to raise_error(NameError)
          end
        end
      end
      describe "returned model" do
        let(:built_model) {subject.ingest}
        it "should populate datastreams" do
          Array.wrap(built_model.title).first.should == "Mexican workers"
        end
        it "should populate file datastreams" do
          built_model.content.content.should == File.open(File.join(bag.data_dir, 'content.png'), 'rb').read
        end
        it "should be new" do
          expect(built_model).to be_new
        end
        it "should not be persisted" do
          expect(built_model).not_to be_persisted
        end
        context "when old_subject has been set" do
          before(:each) do
            subject.old_subject = "http://oregondigital.org/resource/oregondigital:1"
          end
          it "should only replace those subjects" do
            expect(built_model.title.first).to eq "Test Title"
          end
        end
        context "when there is a file datastream and no matching datastream defined" do
          before(:each) do
            # Add the hydra.png from fixture
            FakeFS.deactivate!
            hybag_content = File.read(File.join(FIXTURE_PATH,"hydra.png"))
            FakeFS.activate!
            File.open(File.join(bag.data_dir,"new_content.png"),'wb') {|f| f.puts hybag_content}
          end
          it "should add that datastream" do
            expect(built_model.datastreams.keys).to include("new_content")
          end
        end
        context "when there is a metadata stream and no matching datastream defined" do
          before(:each) do
            # Add the example_datastream.nt from fixture
            FakeFS.deactivate!
            @hybag_content = File.read(File.join(FIXTURE_PATH,"example_datastream.nt"))
            FakeFS.activate!
            bag.add_tag_file("example_datastream.nt") do |f|
              f.write @hybag_content
            end
          end
          it "should add that file as a datastream" do
            expect(built_model.datastreams.keys).to include("example_datastream")
            expect(built_model.datastreams.values.find{|x| x.dsid == "example_datastream"}.content).to eq @hybag_content.strip
          end
          context "and it's an RDF datastream" do
            it "should replace the subject"
          end
        end
        context "when there is an unregistered tag file and no matching datastream defined" do
          before(:each) do
            FakeFS.deactivate!
            @hybag_content = File.read(File.join(FIXTURE_PATH,"example_datastream.nt"))
            FakeFS.activate!
            File.open(File.join(bag.bag_dir, "new_tag_file.nt"), 'wb') {|f| f.puts @hybag_content}
          end
          # TODO: Write this when bagit supports returning unmarked tag files.
          xit "should add that datastream" do
            expect(built_model.datastreams.keys).to include("new_tag_file")
            expect(built_model.datastreams.values.find{|x| x.dsid == "new_tag_file"}.content).to eq @hybag_content.strip
          end
        end
      end
    end
  end
end
