module Hybag
  class Validator
    include ActiveModel::Validations
    validate :bag_valid
    attr_reader :bag, :path

    def initialize(bag, path)
      @bag = bag
      @path = path
    end

    def validate!
      unless self.valid?
        raise "Invalid Object for bagging"
      end
    end

    def bag_valid
      errors.add(:bag, "is not valid for bagging.") unless bag.baggable?
    end

  end
end