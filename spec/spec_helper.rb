require 'rspec/autorun'
ENV['environment'] ||= 'test'
# - RSpec adds ./lib to the $LOAD_PATH
require 'hybag'
#Resque.inline = Rails.env.test?
ROOT_PATH = File.dirname(__FILE__)
DUMMY_PATH = File.join(ROOT_PATH,"dummies")

# Support
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
end