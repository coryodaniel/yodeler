require 'spec_helper'

RSpec.describe Yodeler do
  describe 'DSL' do
    context 'instrumentation' do
      describe '#gauge' do
        it 'delegates #gauge to @client' do
          Yodeler.configure { |client| client.adapter(:memory) }
          adapter = Yodeler.client.default_endpoint.adapter

          Yodeler.gauge('test', 3)
          expect(adapter).to have_dispatched(:gauge, 'test').with(3)
        end
      end

      describe '#increment' do
        it 'delegates #increment to @client' do
          Yodeler.configure { |client| client.adapter(:memory) }
          adapter = Yodeler.client.default_endpoint.adapter

          Yodeler.increment('test')
          expect(adapter).to have_dispatched(:increment, 'test').with(1)
        end
      end

      describe '#event' do
        it 'delegates #event to @client' do
          Yodeler.configure { |client| client.adapter(:memory) }
          adapter = Yodeler.client.default_endpoint.adapter

          Yodeler.publish('test', color: 'green')
          expect(adapter).to have_dispatched(:event, 'test').with(color: 'green')
        end
      end

      describe '#timing' do
        it 'delegates #timing to @client' do
          Yodeler.configure { |client| client.adapter(:memory) }
          adapter = Yodeler.client.default_endpoint.adapter

          retval = Yodeler.timing('test') do
            sleep(0.001)
            :green
          end

          expect(retval).to be :green # OH HOW META!1!!
          expect(adapter).to have_dispatched(:timing, 'test').within(1).of(0)
        end
      end
    end

    context 'configuration' do
      context 'when setting the default endpoint name' do
        it 'returns the new default endpoint' do
          Yodeler.configure do |client|
            client.adapter(:memory) { |mem| mem.max_queue_size = 5 }
            client.endpoint(:dashboard).use(:memory) { |mem| mem.max_queue_size = 10 }
            client.default_endpoint_name = :dashboard
          end

          expect(Yodeler.client.default_endpoint).to be Yodeler.client.endpoints[:dashboard]
        end
      end

      context 'when implicitly creating an endpoint' do
        it 'sets the default endpoint' do
          Yodeler.configure do |client|
            client.adapter(:memory) { |mem| mem.max_queue_size = 100 }
          end

          expect(Yodeler.client.default_endpoint.name).to be :default
          expect(Yodeler.client.default_endpoint.adapter).to be_kind_of Yodeler::Adapters::MemoryAdapter
          expect(Yodeler.client.default_endpoint.adapter.max_queue_size).to be 100
        end

        it 'allows skipping a #use block' do
          Yodeler.configure { |client| client.adapter(:memory) }

          expect(Yodeler.client.default_endpoint.name).to be :default
          expect(Yodeler.client.default_endpoint.adapter).to be_kind_of Yodeler::Adapters::MemoryAdapter
        end

        it 'allows registering multiple endpoints' do
          Yodeler.configure do |client|
            client.adapter(:memory)
            client.endpoint(:sales_dashboard).use(:memory)
          end

          expect(Yodeler.client.endpoints.keys).to eq [:default, :sales_dashboard]
        end
      end

      context 'when naming an endpoint' do
        it 'makes the first endpoint the default' do
          Yodeler.configure do |client|
            client.endpoint(:ops_dashboard).use(:memory)
            client.endpoint(:sales_dashboard).use(:memory)
          end

          expect(Yodeler.client.default_endpoint).to be Yodeler.client.endpoints[:ops_dashboard]
        end

        it 'allows registering multiple endpoints' do
          Yodeler.configure do |client|
            client.endpoint(:ops_dashboard).use(:memory)
            client.endpoint(:sales_dashboard).use(:memory)
          end

          expect(Yodeler.client.endpoints.keys).to eq [:ops_dashboard, :sales_dashboard]
        end

        it 'configuring the adapter with a block' do
          Yodeler.configure do |client|
            client.endpoint(:sales_dashboard).use(:memory)
            client.endpoint(:ops_dashboard).use(:memory) do |memory|
              memory.max_queue_size = 20
            end
          end

          endpoints = Yodeler.client.endpoints
          expect(endpoints.length).to be 2
          expect(endpoints[:ops_dashboard].adapter.max_queue_size).to be 20
        end

        # Forward proofing adding configurations to an endpoint besides the adapter
        it 'allow nested block configuration of the endpoint and adapter' do
          Yodeler.configure do |client|
            client.endpoint(:ops_dashboard).use(:memory) do |memory|
              memory.max_queue_size = 20
            end

            client.endpoint(:sales_dashboard) do |sales_dashboard|
              sales_dashboard.use(:memory) do |memory|
                memory.max_queue_size = 20
              end
            end
          end

          endpoints = Yodeler.client.endpoints
          expect(endpoints[:ops_dashboard].adapter.max_queue_size).to be 20
          expect(endpoints[:sales_dashboard].adapter.max_queue_size).to be 20
        end
      end
    end
  end
end
