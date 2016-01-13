module Yodeler
  class Endpoint
    attr_reader :name
    attr_reader :adapter

    def initialize(name)
      @name = name
      yield(self) if block_given?
    end

    # Set the adapter this endpoint will use
    #
    # @example
    #   endpoint = Yodeler::Endpoint.new(:dashboard)
    #   endpoint.use(:http)
    #
    # @example
    #   endpoint = Yodeler::Endpoint.new(:dashboard)
    #   endpoint.use(:http) do |http|
    #     #your adapter setup here
    #   end
    #
    # @param [Symbol] name the registered name of the adapter
    # @return [~Yodeler::Adapters::Base] yodeler adapter
    def use(name)
      @adapter = Yodeler.registered_adapters(name).new
      yield(@adapter) if block_given?
      @adapter
    end

    attr_reader :adapter
  end
end
