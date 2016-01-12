module Yodeler
  class DuplicateEndpointNameError < StandardError
    attr_reader :name
    def initialize(name:)
      @name = name
      super("An instance of Yodeler::Endpoint named '#{name}' already exists.")
    end
  end
end
