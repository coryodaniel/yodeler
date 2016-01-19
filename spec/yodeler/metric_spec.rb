require 'spec_helper'

RSpec.describe Yodeler::Metric do
  it 'knows its type' do
    metric = Yodeler::Metric.new(:gauge, 'test', 10)
    expect(metric).to be_gauge
    expect(metric).to_not be_increment
  end

  describe '#sample?' do
    let(:metric) { Yodeler::Metric.new(:gauge, 'test', 1, sample_rate: 0.75) }
    context 'when it is not chosen to be sampled' do
      it do
        allow(metric).to receive(:rand).and_return(0.88)
        expect(metric).to_not be_sample
      end
    end

    context 'when it is chosen to be sampled' do
      it do
        allow(metric).to receive(:rand).and_return(0.74)
        expect(metric).to be_sample
      end
    end
  end

  describe '#name' do
    context 'when it has a prefix' do
      it 'prefixes the name' do
        metric = Yodeler::Metric.new(:gauge, 'test', 20, prefix: 'foo')
        expect(metric.name).to eq 'foo.test'
      end
    end

    it 'returns the name' do
      metric = Yodeler::Metric.new(:gauge, 'test', 20)
      expect(metric.name).to eq 'test'
    end
  end

  describe '#to_hash' do
    it 'hashifies the metric' do
      now = Time.now.utc.iso8601
      metric = Yodeler::Metric.new(:gauge, 'test', 20,{
        tags: %w(one two),
        hostname: 'localhost',
        sample_rate: 1.0,
        timestamp: now
      })

      expect(metric.to_hash).to eq(type: :gauge,
                                   uuid: "7ad1ef6a-e71c-4179-99e7-06c8f62151ce",
                                   name: 'test',
                                   value: 20,
                                   tags: %w(one two),
                                   hostname: 'localhost',
                                   timestamp: now)
    end

    context 'when it has a prefix' do
      it 'prefixes the name' do
        metric = Yodeler::Metric.new(:gauge, 'test', 20, prefix: 'foo')
        expect(metric.to_hash).to eq(type: :gauge,
                                     uuid: "7ad1ef6a-e71c-4179-99e7-06c8f62151ce",
                                     name: 'foo.test',
                                     value: 20)
      end
    end
  end
end
