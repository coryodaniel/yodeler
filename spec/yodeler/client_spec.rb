require 'spec_helper'

RSpec.describe Yodeler::Client do
  describe 'instrumentation' do
    let(:client) do
      client = Yodeler::Client.new
      client.adapter(:memory)
      client
    end
    let(:adapter){ client.default_endpoint.adapter }

    pending '#set' #Sets count the number of unique values passed to a key.
    pending '#decrement'

    describe '#gauge' do
      pending ':delta option' #amount to change gauge by

      it "dispatches a 'gauge' metric" do
        expect{ client.gauge('users.count', 100) }.
          to change(adapter.queue, :length).by(1)

        expect(adapter.queue.last.name).to eq 'users.count'
      end
    end

    describe '#increment' do
      context 'when the increment amount is given' do
        it "dispatches an 'increment' metric" do
          expect{ client.increment('users.count', 1) }.
            to change(adapter.queue, :length).by(1)

          expect(adapter.queue.last.name).to eq 'users.count'
          expect(adapter.queue.last.value).to be 1
        end
      end

      context 'when the increment amount is not given' do
        it "dispatches an 'increment' metric" do
          expect{ client.increment('users.count') }.
            to change(adapter.queue, :length).by(1)

          expect(adapter.queue.last.name).to eq 'users.count'
          expect(adapter.queue.last.value).to be 1
        end
      end

      context 'when the options are the second argument' do
        it "dispatches an 'increment' metric" do
          expect{ client.increment('users.count', prefix: :test) }.
            to change(adapter.queue, :length).by(1)

          expect(adapter.queue.last.name).to eq 'test.users.count'
          expect(adapter.queue.last.value).to be 1
        end
      end
    end

    describe '#timing' do
      context 'when receiving a block' do
        context 'when options are provided' do
          it "dispatches a 'timing' metric and returns the result of the block" do
            retval = client.timing 'eat.sandwich', {prefix: :test} do
              sleep(0.00001)
              'it had cheese on it'
            end

            expect(retval).to eq 'it had cheese on it'
            expect(adapter).to have_dispatched(:timing, 'test.eat.sandwich').within(1).of(0)
          end
        end

        it "dispatches a 'timing' metric and returns the result of the block" do
          retval = client.timing('eat.sandwich') do
            sleep(0.00001)
            'it had cheese on it'
          end

          expect(retval).to eq 'it had cheese on it'
          expect(adapter).to have_dispatched(:timing, 'eat.sandwich').within(1).of(0)
        end
      end

      it "dispatches a 'timing' metric" do
        client.timing 'eat.sandwich', 250
        expect(adapter).to have_dispatched(:timing, 'eat.sandwich').with(250)
      end

      it "dispatches a 'timing' metric" do
        client.timing 'eat.sandwich', 500, {prefix: 'test'}
        expect(adapter).to have_dispatched(:timing, 'test.eat.sandwich').with(500)
      end
    end

    describe '#event' do
      it "dispatches an event" do
        payload = {name: "Roy", avatar: "http://example.com/fat-chicken.jpg"}
        client.publish('user.sign_up', payload)
        expect(adapter).to have_dispatched(:event, 'user.sign_up').with(payload)
      end
    end

    context 'when passed the :sample_rate option' do
      context "when the metric is not sampled" do
        it "does not dispatch the metric" do
          expect_any_instance_of(Yodeler::Metric).to receive(:rand).and_return(0.99)
          client.increment("users.count", sample_rate: 0.75)
          expect(adapter).to_not have_dispatched(:increment, "users.count")
        end
      end
    end

    context 'when passed the :to option' do
      it "dispatches to the correct adapters" do
        client = Yodeler::Client.new
        ops_adapter   = client.endpoint(:ops_dashboard).use(:memory)
        sales_adapter = client.endpoint(:sales_dashboard).use(:memory)

        client.gauge 'checkout.cart_size', 3, to: [:sales_dashboard]

        expect(ops_adapter).to_not have_dispatched(:gauge, 'checkout.cart_size')
        expect(sales_adapter).to have_dispatched(:gauge, 'checkout.cart_size').with(3)
      end
    end
  end

  describe '#format_options' do
    let(:client) do
      client = Yodeler::Client.new
      client.adapter(:memory)
      client
    end
    let(:adapter){ client.default_endpoint.adapter }

    describe ':sample_rate' do
      context 'when not provided' do
        it "defaults to the Client#default_sample_rate" do
          client.default_sample_rate = 0.5
          opts = client.format_options({})
          expect(opts[:sample_rate]).to eq 0.5
        end
      end

      it "defaults to the Client#default_prefix" do
        opts = client.format_options({sample_rate: 0.75})
        expect(opts[:sample_rate]).to eq 0.75
      end
    end

    describe ':prefix' do
      context 'when not provided' do
        it "defaults to the Client#default_prefix" do
          client.default_prefix = :bar
          opts = client.format_options({})
          expect(opts[:prefix]).to eq :bar
        end
      end

      it "defaults to the Client#default_prefix" do
        opts = client.format_options({prefix: :foo})
        expect(opts[:prefix]).to eq :foo
      end
    end

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
          memory.max_queue_size = 10
        end

        expect(client).to have_endpoint(:default).using(:memory)
        expect(client.default_endpoint.adapter.max_queue_size).to be 10
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
