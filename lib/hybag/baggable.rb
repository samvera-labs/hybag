module Hybag
  module Baggable
    # @return [BagIt::Bag] The bag that was created on the filesystem.
    def write_bag(path)
      Hybag::Validator.new(self, path).validate!
    end

    def baggable?
      true
    end

  end
end