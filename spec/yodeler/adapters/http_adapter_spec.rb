require 'spec_helper'

RSpec.describe Yodeler::Adapters::HttpAdapter do
  before { Yodeler.register_adapter(:http, Yodeler::Adapters::HttpAdapter) }

  describe '#dispatch' do
    it 'adds the metric to the queue' do
      stub_request(:post, 'http://example.com')
      adapter = Yodeler::Adapters::HttpAdapter.new('example.com')
      metric = Yodeler::Metric.new(:gauge, 'test', 35)

      adapter.dispatch(metric)

      expect(WebMock).to have_requested(:post, 'http://example.com')
        .with(body: "{\"name\":\"test\",\"type\":\"gauge\",\"value\":35}")
    end
  end

  describe '#url' do
    context 'when setting the port' do
      it do
        adapter = Yodeler::Adapters::HttpAdapter.new('example.com', port: 3030)
        expect(adapter.url).to match(':3030')
      end
    end

    context 'when using https' do
      it do
        adapter = Yodeler::Adapters::HttpAdapter.new('example.com', use_ssl: true)
        expect(adapter.url).to match('https://')
      end
    end

    context 'when using http' do
      it do
        adapter = Yodeler::Adapters::HttpAdapter.new('example.com', use_ssl: false)
        expect(adapter.url).to match('http://')
      end
    end
  end

  describe '#handle' do
    context 'overwriting the default handler' do
      it 'calls the handler when dispatched' do
        adapter = Yodeler::Adapters::HttpAdapter.new('example.com', path: '/events')
        metric = Yodeler::Metric.new(:gauge, 'test', 35)

        stub_request(:get, 'http://example.com/events')

        adapter.handle(:default) do |url, metric|
          HTTP.get(url, json: metric.to_hash)
        end

        adapter.dispatch(metric)

        expect(WebMock).to have_requested(:get, 'http://example.com/events')
          .with(body: "{\"name\":\"test\",\"type\":\"gauge\",\"value\":35}")
      end
    end

    context 'overwriting a specific metric handler' do
      it 'calls the handler when dispatched' do
        adapter = Yodeler::Adapters::HttpAdapter.new('example.com')

        stub_request(:post, 'http://example.com')
        stub_request(:get, 'http://example.com')

        adapter.handle(:gauge) do |url, metric|
          HTTP.get(url, json: metric.to_hash)
        end

        increment = Yodeler::Metric.new(:increment, 'test.increment', 1)
        gauge = Yodeler::Metric.new(:gauge, 'test.gauge', 35)
        adapter.dispatch(increment)
        adapter.dispatch(gauge)

        expect(WebMock).to have_requested(:post, 'http://example.com')
          .with(body: "{\"name\":\"test.increment\",\"type\":\"increment\",\"value\":1}")

        expect(WebMock).to have_requested(:get, 'http://example.com')
          .with(body: "{\"name\":\"test.gauge\",\"type\":\"gauge\",\"value\":35}")
      end
    end
  end

  describe '#default_params=' do
    it 'makes an HTTP request with the additional parameters' do
      adapter = Yodeler::Adapters::HttpAdapter.new('example.com', params: { auth_token: 'SECURZ' })
      stub_request(:post, 'http://example.com')

      gauge = Yodeler::Metric.new(:gauge, 'test.gauge', 35)
      adapter.dispatch(gauge)

      expect(WebMock).to have_requested(:post, 'http://example.com')
        .with(body: "{\"auth_token\":\"SECURZ\",\"name\":\"test.gauge\",\"type\":\"gauge\",\"value\":35}")
    end
  end

  describe 'configuring from Yodeler' do
    it 'sets client to use the HTTP adapter' do
      Yodeler.configure do |client|
        client.adapter(:http) do |http|
          http.path = '/events'
          http.host = 'example.com'
          http.use_ssl = true
        end
      end

      expect(Yodeler.client).to have_endpoint(:default).using(:http)
      adapter = Yodeler.client.default_endpoint.adapter

      expect(adapter.path).to eq '/events'
      expect(adapter.host).to eq 'example.com'
      expect(adapter.use_ssl).to be true
    end
  end

  describe 'dispatching from Yodeler' do
    it 'POSTs the metric' do
      Yodeler.configure do |client|
        client.adapter(:http) do |http|
          http.path = '/events'
          http.host = 'example.com'
          http.use_ssl = true
        end
      end

      stub_request(:post, 'https://example.com/events')

      gauge = Yodeler::Metric.new(:gauge, 'test.users.count', 35)

      Yodeler.gauge 'users.count', 35, prefix: :test

      expect(WebMock).to have_requested(:post, 'https://example.com/events')
        .with(body: hash_including(name: 'test.users.count'))
    end
  end
end
