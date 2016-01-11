require 'spec_helper'

RSpec.describe Yodeler do
  describe 'DSL' do
    context 'instrumentation' do
      context 'when reporting to multiple endpoints' do
        describe '#to'
        describe 'the :to option'
      end
    end

    context "configuration" do
      context "when setting the default endpoint name" do
        it "returns the new default endpoint" do
          Yodeler.configure do |client|
            client.adapter(:memory){ |mem| mem.prefix = :bar }
            client.endpoint(:dashboard).use(:memory){ |mem| mem.prefix = :bar }
            client.default_endpoint_name = :dashboard
          end

          expect(Yodeler.client.default_endpoint).to be Yodeler.client.endpoints[:dashboard]
        end
      end

      context "when implicitly creating an endpoint" do
        it "sets the default endpoint" do
          Yodeler.configure do |client|
            client.adapter(:memory){ |mem| mem.prefix = :bar }
          end

          expect(Yodeler.client.default_endpoint.name).to be :default
          expect(Yodeler.client.default_endpoint.adapter).to be_kind_of Yodeler::Adapters::MemoryAdapter
          expect(Yodeler.client.default_endpoint.adapter.prefix).to be :bar
        end

        it "allows skipping a #use block" do
          Yodeler.configure{|client| client.adapter(:memory)}

          expect(Yodeler.client.default_endpoint.name).to be :default
          expect(Yodeler.client.default_endpoint.adapter).to be_kind_of Yodeler::Adapters::MemoryAdapter
        end

        it "allows registering multiple endpoints" do
          Yodeler.configure do |client|
            client.adapter(:memory)
            client.endpoint(:sales_dashboard).use(:memory)
          end

          expect(Yodeler.client.endpoints.keys).to eq [:default, :sales_dashboard]
        end
      end

      context "when naming an endpoint" do
        it "makes the first endpoint the default" do
          Yodeler.configure do |client|
            client.endpoint(:ops_dashboard).use(:memory)
            client.endpoint(:sales_dashboard).use(:memory)
          end

          expect(Yodeler.client.default_endpoint).to be Yodeler.client.endpoints[:ops_dashboard]
        end

        it "allows registering multiple endpoints" do
          Yodeler.configure do |client|
            client.endpoint(:ops_dashboard).use(:memory)
            client.endpoint(:sales_dashboard).use(:memory)
          end

          expect(Yodeler.client.endpoints.keys).to eq [:ops_dashboard, :sales_dashboard]
        end

        it "configuring the adapter with a block" do
          Yodeler.configure do |client|
            client.endpoint(:sales_dashboard).use(:memory)
            client.endpoint(:ops_dashboard).use(:memory) do |memory|
              memory.prefix = :foo
            end
          end

          endpoints = Yodeler.client.endpoints
          expect(endpoints.length).to be 2
          expect(endpoints[:ops_dashboard].adapter.prefix).to be :foo
        end

        # Forward proofing adding configurations to an endpoint besides the adapter
        it "allow nested block configuration of the endpoint and adapter" do
          Yodeler.configure do |client|
            client.endpoint(:ops_dashboard).use(:memory) do |memory|
              memory.prefix = :foo
            end

            client.endpoint(:sales_dashboard) do |sales_dashboard|
              sales_dashboard.use(:memory) do |memory|
                memory.prefix = :bar
              end
            end
          end

          endpoints = Yodeler.client.endpoints
          expect(endpoints[:ops_dashboard].adapter.prefix).to be :foo
          expect(endpoints[:sales_dashboard].adapter.prefix).to be :bar
        end
      end

    end

  end

end
