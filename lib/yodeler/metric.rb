class Yodeler::Metric
  attr_reader :type, :value
  attr_reader :sample_rate, :tags, :prefix

  def initialize(type, name, value, opts={})
    @type = type
    @name = name
    @value = value
    @prefix = opts.delete(:prefix)
    @sample_rate = opts.delete(:sample_rate)
  end

  def name
    @prefix ? [@prefix, @name].join('.') : @name
  end

  # @return [Boolean] Should this metric be sampled
  def sample?
    @_sample ||= !(rand()> @sample_rate)
  end
end
