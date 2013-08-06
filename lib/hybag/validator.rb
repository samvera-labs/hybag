module Hybag
  class Validator
    include ActiveModel::Validations
    validate :bag_valid
    validate :path_not_exist
    attr_reader :bag, :path

    def initialize(bag, path)
      @bag = bag
      @path = path
    end

    def validate!
      unless self.valid?
        raise self.errors.full_messages.join(",")
      end
    end

    def bag_valid
      errors.add(:bag, "is not valid for bagging.") unless bag.baggable?
    end

    def path_not_exist
        errors.add(:path, "must not exist.") if File.exists?(path)
    end

  end
end