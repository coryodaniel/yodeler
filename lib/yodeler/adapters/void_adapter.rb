module Yodeler::Adapters
  class VoidAdapter
    include Yodeler::Adapters::Base

    private

    def record_metric(*)
      #noop
    end

    def record_event(*)
      #noop
    end

    Yodeler.register_adapter(:void, self)
  end
end
