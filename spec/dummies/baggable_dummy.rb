class TestDatastream < ActiveFedora::NtriplesRDFDatastream
  map_predicates do |map|
    map.title(:in => RDF::DC)
  end
end
class BaggableDummy < ActiveFedora::Base
  include Hybag::Baggable
  has_metadata 'descMetadata', type: TestDatastream
end