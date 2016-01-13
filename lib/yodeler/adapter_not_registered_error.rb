module Yodeler
  class AdapterNotRegisteredError < StandardError
    attr_reader :name
    def initialize(name:)
      @name = name
      msg = [
        "No Yodeler Adapter registed for: ':#{name}'",
        'Register an adapter with:',
        "Yodeler.register_adapter(:#{name}, CustomAdapterClass)"
      ].join("\n")
      super(msg)
    end
  end
end
