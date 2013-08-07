require 'active_fedora'
require 'bagit'
require 'mime-types'

module Hybag
  extend ActiveSupport::Autoload

  autoload :Version
  autoload :Baggable
  autoload :Validator
  autoload :BagWriter

end
