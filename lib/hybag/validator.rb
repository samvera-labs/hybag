module Hybag
  class Validator
    include ActiveModel::Validations
    def initialize(object, path)
      @object = object
      @path = path
    end

  end
end