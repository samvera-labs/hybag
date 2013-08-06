require 'rspec/autorun'
ENV['environment'] ||= 'test'
# - RSpec adds ./lib to the $LOAD_PATH
require 'hybag'
#Resque.inline = Rails.env.test?
DUMMY_PATH = File.join(File.dirname(__FILE__),"dummies")
RSpec.configure do |config|
end