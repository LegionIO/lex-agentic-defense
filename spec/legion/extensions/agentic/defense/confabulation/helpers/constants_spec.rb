# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Defense::Confabulation::Helpers::Constants do
  describe 'MAX_CLAIMS' do
    it 'is 500' do
      expect(described_class::MAX_CLAIMS).to eq(500)
    end
  end

  describe 'CONFABULATION_THRESHOLD' do
    it 'is 0.6' do
      expect(described_class::CONFABULATION_THRESHOLD).to eq(0.6)
    end
  end

  describe 'EVIDENCE_DECAY' do
    it 'is 0.02' do
      expect(described_class::EVIDENCE_DECAY).to eq(0.02)
    end
  end

  describe 'RISK_LABELS' do
    it 'covers the full 0.0-1.0 range' do
      expect(described_class::RISK_LABELS.keys.map(&:min).min).to eq(0.0)
      expect(described_class::RISK_LABELS.keys.map(&:max).max).to eq(1.0)
    end

    it 'includes all five risk levels' do
      labels = described_class::RISK_LABELS.values
      expect(labels).to include(:minimal, :low, :moderate, :high, :extreme)
    end

    it 'maps 0.0 to minimal' do
      label = described_class::RISK_LABELS.find { |range, _| range.cover?(0.0) }&.last
      expect(label).to eq(:minimal)
    end

    it 'maps 0.9 to extreme' do
      label = described_class::RISK_LABELS.find { |range, _| range.cover?(0.9) }&.last
      expect(label).to eq(:extreme)
    end
  end

  describe 'CLAIM_TYPES' do
    it 'includes all five types' do
      expect(described_class::CLAIM_TYPES).to include(
        :factual, :causal, :explanatory, :predictive, :autobiographical
      )
    end

    it 'is frozen' do
      expect(described_class::CLAIM_TYPES).to be_frozen
    end
  end
end
