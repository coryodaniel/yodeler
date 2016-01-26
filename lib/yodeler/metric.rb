require 'securerandom'

module Yodeler
  class Metric
    attr_reader :type, :value
    attr_reader :sample_rate, :tags, :prefix
    attr_reader :uuid
    attr_reader :options

    TYPES = [:event, :increment, :gauge, :timing]

    def initialize(type, name, value, opts = {})
      @uuid = SecureRandom.uuid
      @type = type
      @name = name
      @value = value
      @prefix = opts.delete(:prefix)
      @sample_rate = opts.delete(:sample_rate)
      @timestamp = opts.delete(:timestamp)
      @tags = opts.delete(:tags)
      @hostname = opts.delete(:hostname)
      @meta = opts.delete(:meta) || {} #additional meta data to send
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
        uuid: uuid,
        name: name,
        type: @type,
        value: @value,
        meta: @meta
      }

      hash[:meta][:timestamp] = @timestamp if @timestamp
      hash[:meta][:tags] = @tags if @tags && @tags.any?
      hash[:meta][:hostname] = @hostname if @hostname

      hash
    end

    TYPES.each do |type_meth|
      define_method("#{type_meth}?") do
        type_meth.to_sym == type
      end
    end
  end
end
