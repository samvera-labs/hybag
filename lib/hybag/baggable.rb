module Hybag
  module Baggable
    attr_reader :bag
    # @return [BagIt::Bag] The bag that was created on the filesystem.
    def write_bag(path)
      Hybag::Validator.new(self, path).validate!
      # Delete currently existing bag
      FileUtils.rm_rf path if File.directory? path
      # Make and write the bag
      FileUtils.mkdir_p path
      @bag = BagIt::Bag.new(path)
      Hybag::BagWriter.new(self, @bag).write!
    end

    def baggable?
      true
    end

  end
end