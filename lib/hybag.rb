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
    return self.bulk_ingest(bag) if self.bulk_directory?(bag)
    bag = BagIt::Bag.new(bag.to_s) unless bag.kind_of?(BagIt::Bag)
    ingester = Hybag::Ingester.new(bag)
    yield(ingester) if block_given?
    ingester.ingest
  end

  def self.bulk_ingest(directory)
    objects = []
    Hybag::BulkIngester.new(directory).each do |ingester|
      yield(ingester) if block_given?
      objects << ingester.ingest
    end
    return objects
  end

  def self.bulk_directory?(directory)
    Dir.glob(File.join(directory,"*")).select{|x| File.directory?(x) && File.exist?(File.join(x, "bagit.txt"))}.length > 0
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
