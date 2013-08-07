require 'active_fedora'
require 'bagit'
require 'mime-types'

module Hybag
  extend ActiveSupport::Autoload

  require :Version
  require :Baggable
  require :Validator
  require :BagWriter

end
