module Yodeler
  class Metric
    attr_reader :type, :value
    attr_reader :sample_rate, :tags, :prefix
    attr_reader :options

    TYPES = [:event, :increment, :gauge, :timing]

    def initialize(type, name, value, opts = {})
      @type = type
      @name = name
      @value = value
      @prefix = opts.delete(:prefix)
      @sample_rate = opts.delete(:sample_rate)
      @options = opts
    end

    def name
      @prefix ? [@prefix, @name].join('.') : @name
    end

    # @return [Boolean] Should this metric be sampled
    def sample?
      @_sample ||= !(rand > @sample_rate)
    end

    def to_hash
      hash = {
        name: name,
        type: @type,
        value: @value
      }

      hash[:tags] = options[:tags] if options[:tags] && options[:tags].any?
      hash[:hostname] = options[:hostname] if options[:hostname]

      hash
    end

    TYPES.each do |type_meth|
      define_method("#{type_meth}?") do
        type_meth.to_sym == type
      end
    end
  end
end
