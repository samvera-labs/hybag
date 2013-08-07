require 'active_fedora'
require 'bagit'

module Hybag
  extend ActiveSupport::Autoload

  autoload :Version
  autoload :Baggable
  autoload :Validator
  autoload :BagWriter

end
