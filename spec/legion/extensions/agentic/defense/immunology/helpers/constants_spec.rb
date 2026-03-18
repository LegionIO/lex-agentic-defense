# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Defense::Immunology::Helpers::Constants do
  describe 'DEFAULT_RESISTANCE' do
    it 'is 0.5' do
      expect(described_class::DEFAULT_RESISTANCE).to eq(0.5)
    end
  end

  describe 'RESISTANCE_BOOST' do
    it 'is 0.1' do
      expect(described_class::RESISTANCE_BOOST).to eq(0.1)
    end
  end

  describe 'RESISTANCE_DECAY' do
    it 'is 0.02' do
      expect(described_class::RESISTANCE_DECAY).to eq(0.02)
    end
  end

  describe 'MAX_THREATS' do
    it 'is 500' do
      expect(described_class::MAX_THREATS).to eq(500)
    end
  end

  describe 'MAX_ANTIBODIES' do
    it 'is 200' do
      expect(described_class::MAX_ANTIBODIES).to eq(200)
    end
  end

  describe 'THREAT_LABELS' do
    it 'labels 0.9 as critical' do
      label = described_class::THREAT_LABELS.find { |r, _| r.cover?(0.9) }&.last
      expect(label).to eq(:critical)
    end

    it 'labels 0.7 as severe' do
      label = described_class::THREAT_LABELS.find { |r, _| r.cover?(0.7) }&.last
      expect(label).to eq(:severe)
    end

    it 'labels 0.5 as moderate' do
      label = described_class::THREAT_LABELS.find { |r, _| r.cover?(0.5) }&.last
      expect(label).to eq(:moderate)
    end

    it 'labels 0.3 as low' do
      label = described_class::THREAT_LABELS.find { |r, _| r.cover?(0.3) }&.last
      expect(label).to eq(:low)
    end

    it 'labels 0.1 as negligible' do
      label = described_class::THREAT_LABELS.find { |r, _| r.cover?(0.1) }&.last
      expect(label).to eq(:negligible)
    end
  end

  describe 'IMMUNITY_LABELS' do
    it 'labels 0.9 as immune' do
      label = described_class::IMMUNITY_LABELS.find { |r, _| r.cover?(0.9) }&.last
      expect(label).to eq(:immune)
    end

    it 'labels 0.1 as compromised' do
      label = described_class::IMMUNITY_LABELS.find { |r, _| r.cover?(0.1) }&.last
      expect(label).to eq(:compromised)
    end
  end

  describe 'MANIPULATION_TACTICS' do
    it 'has 10 tactics' do
      expect(described_class::MANIPULATION_TACTICS.size).to eq(10)
    end

    it 'includes authority_appeal' do
      expect(described_class::MANIPULATION_TACTICS).to include(:authority_appeal)
    end

    it 'includes gaslighting' do
      expect(described_class::MANIPULATION_TACTICS).to include(:gaslighting)
    end
  end
end
