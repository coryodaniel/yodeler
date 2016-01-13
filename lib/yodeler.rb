require 'yaml'
require 'forwardable'

require 'yodeler/version'
require 'yodeler/endpoint'
require 'yodeler/client'
require 'yodeler/metric'

require 'yodeler/duplicate_endpoint_name_error'
require 'yodeler/adapter_not_registered_error'

module Yodeler
  class << self
    extend Forwardable
    def_delegators :@client, :gauge, :increment, :timing, :publish

    #
    # @private
    def setup!
      @client = nil
      @registered_adapters = {}
    end

    def register_adapter(name, klass)
      @registered_adapters[name] = klass
    end

    #
    # @private
    def registered_adapters(name)
      klass = @registered_adapters[name]
      fail AdapterNotRegisteredError.new(name: name) unless klass
      @registered_adapters[name]
    end

    # @private
    def reset!
      setup!
    end

    attr_reader :client

    def configure
      @client = Yodeler::Client.new
      yield @client
      @client
    end
  end
end

Yodeler.setup!
require 'yodeler/adapters/memory_adapter'
require 'yodeler/adapters/http_adapter'
