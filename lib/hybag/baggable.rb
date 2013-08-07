module Hybag
  module Baggable
    attr_reader :bag
    # @return [BagIt::Bag] The bag that was created on the filesystem.
    def write_bag(path='')
      path = bag_path(path)
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

    private

    def bag_path_namespace
      File.join('tmp','bags')
    end

    def bag_path(path='')
      path = Rails.root.join(bag_path_namespace, path) unless path.to_s.start_with? Rails.root.join(bag_path_namespace).to_s
      return File.join(path, self.pid)
    end
  end
end