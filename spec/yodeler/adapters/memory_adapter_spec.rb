require 'spec_helper'

RSpec.describe Yodeler::Adapters::MemoryAdapter do
  describe '#dispatch' do
    it "adds the metric to the queue" do
      adapter = Yodeler::Adapters::MemoryAdapter.new
      metric = double('Yodeler::Metric')
      adapter.dispatch(metric)

      expect{ adapter.dispatch(metric) }.to change{ adapter.queue.length }.by(1)
    end
  end

  describe '#flush!' do
    it "empties the queue" do
      adapter = Yodeler::Adapters::MemoryAdapter.new
      metric = double('Yodeler::Metric')
      adapter.dispatch(metric)

      expect{ adapter.flush! }.to change{ adapter.queue.length }.from(1).to(0)
    end
  end
end
