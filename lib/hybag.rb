require 'active_fedora'

module Hybag
  extend ActiveSupport::Autoload

  autoload :Version
  autoload :Baggable
  autoload :Validator
  autoload :BagWriter

end
