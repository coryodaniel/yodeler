module Yodeler::Adapters
  class VoidAdapter
    def dispatch(*)
      # noop
    end

    Yodeler.register_adapter(:void, self)
  end
end
