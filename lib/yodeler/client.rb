require 'socket'

module Yodeler
  class Client
    attr_accessor :default_endpoint_name
    attr_reader :endpoints

    def initialize
      @endpoints = {}
      @hostname  = Socket.gethostname
    end

    # Register a new endpoint
    #
    # @param [Symbol|String] name of endpoint, must be unique
    # @return [Yodeler::Endpoint]
    def endpoint(name=:default, &block)
      raise DuplicateEndpointNameError.new(name: name) if @endpoints[name]
      @default_endpoint_name ||= name
      @endpoints[name] = Endpoint.new(name,&block)
    end

    # Get the default endpoint
    #
    # @return [Yodeler::Endpoint] Get the default endpoint
    def default_endpoint
      @endpoints[default_endpoint_name]
    end

    # Syntax sugar for creating the default endpoint and set the adapter
    #
    # Useful if you just have one endpoint and don't care about its name
    # like during testing or for simple metric reporting scenarios
    # ... is this useful or is it a big ol' booger?
    #
    # @param [Symbol] name registered adapter name
    # @param [Type] &block configuration for adapter
    # @return [~Yodeler::Adapters::Base] the adapter
    def adapter(name ,&block)
      endpoint() if @endpoints.empty?
      default_endpoint.use(name, &block)
    end

    def gauge(name, value, opts={})
      opts = format_options(opts)

      metric_type = :gauge
      #adapter.prefix
      #@hostname
    end

    # Formats/Defaults metric options
    #
    # @param [Hash] opts metric options
    # @option opts [Array<String,Symbol>, String, Symbol] :tags ([]) array of tags to apply to metric
    # @option opts [Float] :sample_rate (1.0) The sample rate to use
    # @option opts [Array<Symbol>, Symbol] :to array of endpoint names to send the metric to. If not set will send to {Yodeler::Client#default_endpoint_name}
    # @return [Hash] formatted, defaulted options
    def format_options(opts)
      endpoint_names  = opts.delete(:to) || [default_endpoint_name]
      tags            = opts.delete(:tags)

      {
        to:           [endpoint_names].flatten.compact,
        sample_rate:  opts.delete(:sample_rate) || 1.0,
        tags:         [tags].flatten.compact
      }
    end

    private

    def record_metric()
    end

    def record_event()
    end

  end
end
