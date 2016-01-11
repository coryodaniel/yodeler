require "yaml"
require "yodeler/version"
require "yodeler/adapters/base"
require "yodeler/endpoint"
require "yodeler/client"

module Yodeler
  class DuplicateEndpointNameError < StandardError
    attr_reader :name
    def initialize(name:)
      @name = name
      super("An instance of Yodeler::Endpoint named '#{name}' already exists.")
    end
  end

  class AdapterNotRegisteredError < StandardError
    attr_reader :name
    def initialize(name:)
      @name = name
      msg = [
        "No Yodeler Adapter registed for: ':#{name}'",
        "Register an adapter with:",
        "Yodeler.register_adapter(:#{name}, CustomAdapterClass)"
      ].join("\n")
      super(msg)
    end
  end

  class << self

    #
    # @private
    def setup!
      @client = nil
      @registered_adapters = {}
    end

    def register_adapter(name,klass)
      @registered_adapters[name] = klass
    end

    #
    # @private
    def registered_adapters(name)
      klass = @registered_adapters[name]
      if !klass
        raise AdapterNotRegisteredError.new(name: name)
      end
      @registered_adapters[name]
    end

    # @private
    def reset!
      setup!
    end

    def client
      @client
    end

    def configure
      @client = Yodeler::Client.new
      yield @client
      @client
    end
  end
end

Yodeler.setup!
require "yodeler/adapters/memory_adapter"
require "yodeler/adapters/void_adapter"
