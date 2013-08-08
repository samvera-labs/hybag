require 'active_fedora'
require 'bagit'
require 'mime-types'

require 'hybag/version'
require 'hybag/baggable'
require 'hybag/validator'
require 'hybag/bag_writer'
require 'hybag/ingester'

module Hybag
  def self.ingest(bag)
    Hybag::Ingester.new(bag).ingest
  end
end
