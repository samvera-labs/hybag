module Hybag
  module Baggable
    attr_reader :bag
    # @return [BagIt::Bag] The bag that was created on the filesystem.
    def write_bag(path)
      Hybag::Validator.new(self, path).validate!
      # Make and write the bag
      FileUtils.mkdir_p path
      @bag = Bagit::Bag.new(path)
      Bagit::BagWriter.new(self, @bag).write!
    end

    def baggable?
      true
    end

  end
end