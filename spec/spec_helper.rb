require 'rspec/autorun'
ENV['environment'] ||= 'test'
# - RSpec adds ./lib to the $LOAD_PATH
require 'hybag'
#Resque.inline = Rails.env.test?

RSpec.configure do |config|
end