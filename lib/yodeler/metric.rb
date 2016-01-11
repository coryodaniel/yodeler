class Yodeler::Metric
  attr_accessor :type, :name, :value
  attr_accessor :sample_rate, :tags

  # # @return [String]
  # def to_s
  # end

  # @return [String]
  def inspect
    "#<Yodeler::Metric #{self.to_s}>"
  end
end
