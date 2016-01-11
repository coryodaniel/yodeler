module ClientHelper
  extend RSpec::Matchers::DSL

  matcher :have_endpoint do |endpoint_name|
    match do |client|
      @endpoint = client.endpoints[endpoint_name]
      passed = @endpoint.kind_of?(Yodeler::Endpoint)

      if passed
        if @adapter_name
          passed = @endpoint.adapter.class.to_s == lookup_adapter_by_name(@adapter_name)
        elsif @without_adapter
          passed = @endpoint.adapter.nil?
        end
      end

      passed
    end

    chain :using do |adapter_name|
      @adapter_name = adapter_name
    end

    chain :without_adapter do
      @without_adapter = true
    end

    description do |client|
      msg = ["create a client with an endpoint named '#{endpoint_name}'"]
      if @adapter_name
        class_name = lookup_adapter_by_name(@adapter_name)
        msg << "using the '#{class_name}' adapter"
      elsif @without_adapter
        msg << "without an adapter"
      end
      msg.join(' ')
    end

    failure_message do |client|
      msg = ["expected to #{description}"]
      msg << "Registered endpoints:"
      client.endpoints.each do |name, endpoint|
        if endpoint.adapter
          msg << "  #{name} using: #{endpoint.adapter.class}"
        else
          msg << "  #{name} without an adapter"
        end
      end

      msg.join("\n")
    end

    def lookup_adapter_by_name(name)
      Yodeler.registered_adapters(name).to_s
    end
  end
end
