module Hybag
  module Baggable
    # @return [BagIt::Bag] The bag that was created on the filesystem.
    def write_bag(path)
      HyBag::
      raise "Item is not valid for bagging." unless self.baggable?
      # Check to make sure the directory is empty or nonexistent.
      raise "Given path is not empty." unless self.valid_baggable_path?(path)
    end

    def baggable?
      true
    end

  end
end