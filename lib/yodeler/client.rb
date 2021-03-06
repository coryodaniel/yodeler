require 'socket'

module Yodeler
  class Client
    attr_accessor :default_endpoint_name
    attr_accessor :default_prefix
    attr_accessor :default_sample_rate
    attr_accessor :timestamp_format
    attr_reader :endpoints

    TIMESTAMP_FORMATS = {
      iso8601: -> { Time.now.utc.iso8601 },
      epoch:   -> { Time.now.to_i }
    }

    def initialize
      @endpoints = {}
      @default_sample_rate = 1.0
      @default_prefix = nil
      @hostname = Socket.gethostname
      @timestamp_format = :iso8601
    end

    def timestamp_generator
      if timestamp_format.is_a?(Symbol) && TIMESTAMP_FORMATS[timestamp_format]
        TIMESTAMP_FORMATS[timestamp_format].call
      elsif timestamp_format.is_a?(Proc)
        timestamp_format.call
      else
        raise ArgumentError, "Time format not recognized: #{timestamp_format}. \nOptions are #{TIMESTAMP_FORMATS.join(', ')} or a lamba"
      end
    end

    # Register a new endpoint
    #
    # @param [Symbol|String] name of endpoint, must be unique
    # @return [Yodeler::Endpoint]
    def endpoint(name = :default, &block)
      fail DuplicateEndpointNameError.new(name: name) if @endpoints[name]
      @default_endpoint_name ||= name
      @endpoints[name] = Endpoint.new(name, &block)
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
    def adapter(name, &block)
      endpoint if @endpoints.empty?
      default_endpoint.use(name, &block)
    end

    # Set a gauge
    #
    # @example
    #   client.gauge('users.count', 20_000_000)
    #   client.gauge('users.count', 20_000_000, { tags: %w(something) })
    #
    # @param [~String] name of the metric
    # @param [~Fixnum] value of the metric
    # @param [Hash] opts={} Examples {#format_options}
    # @return [Yodeler::Metric, nil] the dispatched metric, nil if not sampled
    def gauge(name, value, opts = {})
      dispatch(:gauge, name, value, opts)
    end

    # Increment a counter
    #
    # @example
    #   client.increment 'user.signup'
    #   client.increment 'user.signup', {}
    #   client.increment 'user.signup', 1, {}
    #
    # @param [~String] name of the metric
    # @param [~Fixnum] value=1 of the metric
    # @param [Hash] opts={} Examples {#format_options}
    # @return [Yodeler::Metric, nil] the dispatched metric, nil if not sampled
    def increment(name, value = 1, opts = {})
      if value.is_a?(Hash)
        opts = value
        value = 1
      end
      dispatch(:increment, name, value, opts)
    end

    # Measure how long something takes
    #
    # @example
    #   client.timing 'eat.sandwich', 250
    #   client.timing('eat.pizza') do
    #     user.eat(pizza) #=> THAT WAS QUICK FATSO!
    #   end
    #
    # @param [~String] name of the metric
    # @param [~Fixnum] value time in ms
    # @param [Hash] opts={} Examples {#format_options}
    # @return [Yodeler::Metric, nil, Object]
    #   the dispatched metric, nil if not sampled
    #   if a block is given the result of the block is returned
    def timing(name, value = nil, opts = {})
      if value.is_a?(Hash)
        opts = value
        value = nil
      end

      retval = nil
      if block_given?
        start = Time.now.to_i
        retval = yield
        value = Time.now.to_i - start
      end

      metric = dispatch(:timing, name, value, opts)
      retval || metric
    end

    # Publish an event
    #
    # @example
    #   client.publish('item.sold', purchase.to_json)
    #   client.publish('user.sign_up', {name: user.name, avatar: user.image})
    #
    # @param [~String] name of the metric
    # @param [~Hash] value of the metric
    # @param [Hash] opts={} Examples {#format_options}
    # @return [Yodeler::Metric, nil] the dispatched metric, nil if not sampled
    def publish(name, payload = {}, opts = {})
      if block_given?
        opts = payload
        payload = {}
        yield(payload)
        dispatch(:event, name, payload, opts)
      else
        dispatch(:event, name, payload, opts)
      end
    end

    # Formats/Defaults metric options
    #
    # @param [Hash] opts metric options
    # @option opts [Array<String,Symbol>, String, Symbol] :tags ([])
    #   array of tags to apply to metric/event
    # @option opts [Float] :sample_rate (1.0) The sample rate to use
    # @option opts [Array<Symbol>, Symbol] :to
    #   array of endpoint names to send the metric to.
    #   If not set will send to {Yodeler::Client#default_endpoint_name}
    # @return [Hash] formatted, defaulted options
    def format_options(opts)
      endpoint_names  = opts.delete(:to) || [default_endpoint_name]
      tags            = opts.delete(:tags)
      prefix          = opts.delete(:prefix) || default_prefix
      timestamp       = opts.delete(:timestamp) || timestamp_generator
      meta            = opts.delete(:meta)

      {
        prefix:       prefix,
        to:           [endpoint_names].flatten.compact,
        sample_rate:  opts.delete(:sample_rate) || default_sample_rate,
        tags:         [tags].flatten.compact,
        hostname:     @hostname,
        timestamp:    timestamp,
        meta:         meta
      }
    end

    private

    def dispatch(type, name, value, opts)
      opts = format_options(opts)
      destinations = opts.delete(:to)

      metric = Metric.new(type, name, value, opts)

      return nil unless metric.sample?

      destinations.each do |endpoint_name|
        if @endpoints[endpoint_name]
          @endpoints[endpoint_name].adapter.dispatch(metric)
        end
      end

      metric
    end
  end
end
