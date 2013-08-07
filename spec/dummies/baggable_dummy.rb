class TestDatastream < ActiveFedora::NtriplesRDFDatastream
  map_predicates do |map|
    map.title(:in => RDF::DC)
  end
end
class BaggableDummy < ActiveFedora::Base
  include Hybag::Baggable
  delegate_to :descMetadata, [:title]
  has_metadata 'descMetadata', type: TestDatastream
  has_file_datastream name: "content"
end