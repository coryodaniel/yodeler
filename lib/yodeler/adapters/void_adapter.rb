module Yodeler::Adapters
  class VoidAdapter
    include Yodeler::Adapters::Base

    def dispatch(*)
      #noop
    end

    Yodeler.register_adapter(:void, self)
  end
end
