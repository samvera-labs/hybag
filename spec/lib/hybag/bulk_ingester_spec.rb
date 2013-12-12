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
describe Hybag::BulkIngester do
  before(:each) do
    @items = []
    5.times do |n|
      item = BaggableDummy.new(:pid => "filler#{n}")
      item.descMetadata.content = File.open(File.join(FIXTURE_PATH,"example_datastream.nt")).read.strip
      content_file = File.open(File.join(FIXTURE_PATH,"hydra.png"))
      item.add_file_datastream(content_file, :dsid => "content", :mimeType => "image/png")
      item.rels_ext.content = File.open(File.join(FIXTURE_PATH,"rels.rdf")).read
      item.load_relationships
      item.stub(:persisted?).and_return(true)
      @items << item
    end
    # Stub Rails root
    rails = double("Rails")
    Rails = rails unless defined?(Rails)
    Rails.stub(:root).and_return(Pathname.new('/test'))
    # Stub ActiveFedora assign_pid
    ActiveFedora::Base.stub(:assign_pid).and_return(*(5.times.map{|x| "new_filler_#{x}"}))
  end
  5.times do |n|
    let("item_#{n}".to_sym) {@items[n]}
    let("bag_#{n}".to_sym) {@items[n].write_bag}
  end
  subject {Hybag::BulkIngester.new("/test/tmp/bags")}
  describe "functionality" do
    include FakeFS::SpecHelpers
    context "when given a directory of bags" do
      before(:each) do
        bag_0
        bag_1
        bag_2
        bag_3
        bag_4
      end
      describe ".each" do
        it "should return an enumerator" do
          expect(subject.each).to be_kind_of(Enumerator)
        end
        it "should return an ingest object" do
          expect(subject.each.first).to be_kind_of(Hybag::Ingester)
        end
      end
      it "should only ingest bagit bags" do
        FileUtils.mkdir('/test/tmp/bags/6')
        expect(subject.each.to_a.length).to eq 5
      end
      it "should be able to ingest a bunch of bags" do
        result = subject.map{|ingester| ingester.ingest}
        expect(result.length).to eq 5
        expect(result.first.pid).to eq "new_filler_0"
        expect(result.first.title).to eq ["Mexican workers"]
      end
    end
  end
end
