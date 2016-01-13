if ENV['CI']
  require 'codeclimate-test-reporter'
  SimpleCov.profiles.define 'default' do
    add_filter 'spec'
  end

  CodeClimate::TestReporter.configure do |config|
    config.profile = 'default'
  end
  CodeClimate::TestReporter.start
else
  require 'simplecov'
  SimpleCov.profiles.define 'default' do
    add_filter 'spec'
  end
  SimpleCov.start 'default'
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pry'
require 'yodeler'

require 'webmock/rspec'
Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |f| require f }

RSpec.configure do |c|
  c.include ConfigHelper
  c.include ClientHelper
  c.after {
    Yodeler.reset!
    Yodeler.register_adapter(:memory, Yodeler::Adapters::MemoryAdapter)
  }

  c.after(:suite) do
    WebMock.disable_net_connect!(allow: 'codeclimate.com')
  end
end
