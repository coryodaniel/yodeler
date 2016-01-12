module Yodeler::Adapters
  class MemoryAdapter
    attr_reader :queue
    attr_accessor :max_queue_size

    def initialize
      @max_queue_size = 1000
      flush!
    end

    def flush!
      @queue = []
    end

    def dispatch(metric)
      @queue << metric
      @queue.shift if @queue.length > @max_queue_size
      metric
    end

    Yodeler.register_adapter(:memory, self)
  end
end
