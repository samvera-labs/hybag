require 'spec_helper'

describe Hybag do
  describe ".ingest" do
    it "should call Hybag::Ingester.ingest" do
      Hybag::Ingester.any_instance.should_receive(:ingest).and_return("bla")
      Hybag.ingest("empty")
    end
  end
end