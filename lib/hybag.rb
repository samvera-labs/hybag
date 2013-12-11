require 'active_fedora'
require 'bagit'
require 'mime-types'

require 'hybag/version'
require 'hybag/baggable'
require 'hybag/validator'
require 'hybag/bag_writer'
require 'hybag/ingester'
require 'hybag/bulk_ingester'

module Hybag
  def self.ingest(bag)
    ingester = Hybag::Ingester.new(bag)
    yield(ingester) if block_given?
    ingester.ingest
  end

  # Error Classes
  class UndiscoverableModelName < StandardError
    def initialize(bag)
      super("Unable to determine model from bag at #{bag.bag_dir}")
    end
  end
  class InvalidBaggable < StandardError
    def initialize(object)
      super("#{object} requested to be bagged, but it is invalid")
    end
  end
end
