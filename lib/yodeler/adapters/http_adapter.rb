require 'http'

module Yodeler::Adapters
  class HttpAdapter
    attr_accessor :host
    attr_accessor :port
    attr_accessor :path
    attr_accessor :use_ssl
    attr_accessor :default_params

    def initialize(host=nil, port:nil, path:nil, use_ssl:false, params:{})
      @host = host
      @port = port
      @path = path
      @use_ssl = use_ssl
      @default_params = params
      @handlers = {}

      handle(:default) do |url, metric, default_params|
        HTTP.post(url, json: default_params.merge(metric.to_hash))
      end
    end

    def handle(type, &block)
      @handlers[type] = block
    end

    def dispatch(metric)
      (@handlers[metric.type] || @handlers[:default]).call(url, metric, default_params)
    end

    def url
      "#{protocol}://#{host_with_port}#{path}"
    end

    private
    def host_with_port
      if port
        "#{host}:#{port}"
      else
        host
      end
    end

    def protocol
      use_ssl ? :https : :http
    end

    Yodeler.register_adapter(:http, self)
  end
end
