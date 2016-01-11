module Yodeler::Adapters
  module Base
    attr_accessor :prefix

    private
    
    def record_metric()
    end

    def record_event()
    end

    def _handle_event(*)
      raise StandardError, "#{self.class.to_s}#_handle_event not implemented!"
    end

    def _handle_metric(*)
      raise StandardError, "#{self.class.to_s}#_handle_metric not implemented!"
    end
  end
end
