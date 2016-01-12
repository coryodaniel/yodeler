require 'spec_helper'

RSpec.describe Yodeler::Metric do
  describe '#sample?' do
    let(:metric){ Yodeler::Metric.new(:gauge, 'test', 1, sample_rate: 0.75)}
    context 'when it is not chosen to be sampled' do
      it {
        allow(metric).to receive(:rand).and_return(0.88)
        expect(metric).to_not be_sample
      }
    end

    context 'when it is chosen to be sampled' do
      it {
        allow(metric).to receive(:rand).and_return(0.74)
        expect(metric).to be_sample
      }
    end
  end

  describe '#name' do
    context 'when it has a prefix' do
      it "prefixes the name" do
        metric = Yodeler::Metric.new(:gauge, 'test', 20, prefix: 'foo')
        expect(metric.name).to eq 'foo.test'
      end
    end

    it "returns the name" do
      metric = Yodeler::Metric.new(:gauge, 'test', 20)
      expect(metric.name).to eq 'test'
    end
  end
end
