require 'spec_helper'

RSpec.describe Yodeler::Client do
  describe 'instrumentation' do
    let(:client) do
      client = Yodeler::Client.new
      client.adapter(:memory)
      client
    end
    let(:adapter){ client.default_endpoint.adapter }

    describe '#format_options' do
      describe ':to' do
        context 'when not provided' do
          it "defaults to the Client#default_endpoint_name" do
            opts = client.format_options({})
            expect(opts[:to]).to eq([:default])
          end
        end

        context 'when an array is provided' do
          it "returns the array" do
            opts = client.format_options({to: [:ops_dashboard, :sales_dashboard]})
            expect(opts[:to]).to eq([:ops_dashboard, :sales_dashboard])
          end
        end

        context 'when a symbol is provided' do
          it "wraps it in an array" do
            opts = client.format_options({to: :sales_dashboard})
            expect(opts[:to]).to eq([:sales_dashboard])
          end
        end
      end

      describe ':tags' do
        context 'when a string is provided' do
          it "wraps it in an array" do
            opts = client.format_options({tags: :sales})
            expect(opts[:tags]).to eq([:sales])
          end
        end

        context 'when an array is provided' do
          it "returns the array" do
            opts = client.format_options({tags: [:sales, :opts]})
            expect(opts[:tags]).to eq([:sales,:opts])
          end
        end
      end

      describe ':sample_rate' do
        context 'when it is not provided' do
          it "defaults to 1.0" do
            opts = client.format_options({})
            expect(opts[:sample_rate]).to eq 1.0
          end
        end

        context 'when it is provided' do
          it "sets the sample rate" do
            opts = client.format_options({sample_rate: 0.5})
            expect(opts[:sample_rate]).to eq 0.5
          end
        end
      end
    end

    describe '#gauge' do
      pending
      # it "" do
      #   client.gauge('users.count', 100)
      #   allow(adapter)
      # end
    end
    #client.gauge 'checkout.cart_size', order.products.count

    describe '#increment'
    #client.increment 'user.signup'
    describe '#decrement'
    #client.increment 'sessions'

    describe '#measure'
    #client.measure 'eating.sandwich', 500 #ms #=> nil
    #client.measure('eating.pizza') do
    # Meal.create!
    #end #=> Meal instance

    describe '#emit'
    # client.emit(category, action, opt_label, opt_value)

    pending '#set'
    pending '#key_value'
    pending '#histogram'
    pending 'when passed the :tags option'
    pending 'when passed the :sample_rate option'
    context 'when passed the :to option' do
      pending
      # client.gauge 'checkout.cart_size', order.products.count,
      #   to: [:sales_dashboard]
    end
  end

  pending '#default_sample_rate'

  describe '#default_endpoint' do
    it "returns the default endpoint" do
      client = Yodeler::Client.new
      client.endpoint(:dashboard)

      expect(client.default_endpoint).to be client.endpoints[:dashboard]
    end
  end

  describe '#endpoint' do
    it "registers a new endpoint" do
      client = Yodeler::Client.new
      client.endpoint(:dashboard)

      expect(client).to have_endpoint(:dashboard).without_adapter
    end

    context "when passing a block" do
      it {
        client = Yodeler::Client.new
        client.endpoint(:dashboard) do |dashboard|
          dashboard.use(:memory)
        end

        expect(client).to have_endpoint(:dashboard).using(:memory)
      }
    end

    context "when calling #use" do
      it{
        client = Yodeler::Client.new
        client.adapter(:memory) do |memory|
          memory.prefix = :bar
        end

        expect(client).to have_endpoint(:default).using(:memory)
        expect(client.default_endpoint.adapter.prefix).to be :bar
      }
    end
  end

  describe '#default_endpoint_name' do
    context "when there is one endpoint" do
      context "when the endpoint doesn't have a name" do
        it "returns 'default'" do
          client = Yodeler::Client.new
          client.endpoint

          expect(client.default_endpoint_name).to be :default
        end
      end

      context "when the endpoint does have a name" do
        it "returns the endpoint's name" do
          client = Yodeler::Client.new
          client.endpoint(:dashboard)

          expect(client.default_endpoint_name).to be :dashboard
        end
      end
    end

    context "when there are multiple endpoints" do
      it "sets the new default endpoint" do
        client = Yodeler::Client.new
        client.endpoint(:dashboard)
        client.endpoint(:dashboard2)
        client.default_endpoint_name = :dashboard2

        expect(client.default_endpoint).to be(client.endpoints[:dashboard2])
      end

      context "when the default endpoint hasn't been set" do
        it "set the first endpoint as default" do
          client = Yodeler::Client.new
          client.endpoint(:dashboard)
          client.endpoint(:dashboard2)

          expect(client.default_endpoint).to be(client.endpoints[:dashboard])
        end
      end
    end
  end
end
