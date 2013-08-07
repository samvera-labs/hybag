module Hybag
  class Validator
    include ActiveModel::Validations
    validate :bag_valid
    validate :require_persisted
    attr_reader :bag

    def initialize(bag)
      @bag = bag
    end

    def validate!
      unless self.valid?
        raise "Invalid Object for bagging"
      end
    end

    def bag_valid
      errors.add(:bag, "is not valid for bagging.") unless bag.baggable?
    end

    def require_persisted
      errors.add(:bag, "is not persisted.") unless bag.persisted?
    end

  end
end