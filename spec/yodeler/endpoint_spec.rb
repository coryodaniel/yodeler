require 'spec_helper'

RSpec.describe Yodeler::Endpoint do
  describe '#initialize' do
    it "sets the endpoint name" do
      endpoint = Yodeler::Endpoint.new('test')
      expect(endpoint.name).to eq 'test'
    end
  end

  describe '#use' do
    context 'when the adapter has been registered' do
      context "when passed a block" do
        it "configures the adapter" do
          Yodeler.configure do |client|
            client.adapter(:memory){ |mem| mem.max_queue_size = 10 }
          end

          expect(Yodeler.client.default_endpoint.adapter.max_queue_size).to be 10
        end
      end

      context "when no block is passed" do
        it "uses the adapter defaults" do
          Yodeler.configure do |client|
            client.adapter(:memory)
          end
          expect(Yodeler.client.default_endpoint.adapter.max_queue_size).to be 1000
        end
      end
    end

    context "when the adapter hasn't been registered" do
      it "raises a Yodeler::AdapterNotRegisteredError" do
        endpoint = Yodeler::Endpoint.new('test')

        expect{endpoint.use(:http)}.to raise_error Yodeler::AdapterNotRegisteredError
      end
    end
  end
end
