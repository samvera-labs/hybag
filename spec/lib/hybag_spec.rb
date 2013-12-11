require 'spec_helper'

describe Hybag do
  describe ".ingest" do
    it "should call Hybag::Ingester.ingest" do
      Hybag::Ingester.any_instance.should_receive(:ingest).and_return("bla")
      Hybag.ingest("empty")
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