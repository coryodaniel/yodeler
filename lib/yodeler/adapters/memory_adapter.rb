module Yodeler::Adapters
  class MemoryAdapter
    include Yodeler::Adapters::Base
    attr_reader :metrics
    attr_reader :events

    def initialize
      flush!
    end

    def flush!
      @metrics  = []
      @events   = []
    end

    private

    def _handle_metric(metric)
      # prefix, tag, hostname
      # This sshould be moved to Base
      # and call a method to be implemented in each adapter
      @metrics << metric
    end

    def _handle_event(event)
      @events << event
    end

    Yodeler.register_adapter(:memory, self)
  end
end
