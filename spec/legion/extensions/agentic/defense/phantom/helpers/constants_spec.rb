# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Defense::Phantom::Helpers::Constants do
  describe 'constants' do
    it 'defines MAX_PHANTOMS as 100' do
      expect(described_class::MAX_PHANTOMS).to eq(100)
    end

    it 'defines INITIAL_INTENSITY as 0.8' do
      expect(described_class::INITIAL_INTENSITY).to eq(0.8)
    end

    it 'defines INTENSITY_DECAY as 0.05' do
      expect(described_class::INTENSITY_DECAY).to eq(0.05)
    end

    it 'defines MIN_INTENSITY as 0.01' do
      expect(described_class::MIN_INTENSITY).to eq(0.01)
    end

    it 'defines four PHANTOM_STATES' do
      expect(described_class::PHANTOM_STATES).to eq(%i[acute adapting residual resolved])
    end

    it 'defines four TRIGGER_TYPES' do
      expect(described_class::TRIGGER_TYPES).to eq(%i[stimulus_match contextual_association temporal_pattern habitual])
    end

    it 'PHANTOM_STATES is frozen' do
      expect(described_class::PHANTOM_STATES).to be_frozen
    end

    it 'TRIGGER_TYPES is frozen' do
      expect(described_class::TRIGGER_TYPES).to be_frozen
    end
  end

  describe '.label_for' do
    it 'returns label for :acute' do
      label = described_class.label_for(:acute)
      expect(label).to be_a(String)
      expect(label).not_to be_empty
    end

    it 'returns label for :adapting' do
      label = described_class.label_for(:adapting)
      expect(label).to be_a(String)
    end

    it 'returns label for :residual' do
      label = described_class.label_for(:residual)
      expect(label).to be_a(String)
    end

    it 'returns label for :resolved' do
      label = described_class.label_for(:resolved)
      expect(label).to be_a(String)
    end

    it 'returns unknown label for unrecognized state' do
      label = described_class.label_for(:nonexistent)
      expect(label).to include('Unknown')
    end
  end

  describe '.state_for' do
    it 'returns :acute for intensity >= 0.6' do
      expect(described_class.state_for(0.8)).to eq(:acute)
      expect(described_class.state_for(0.6)).to eq(:acute)
    end

    it 'returns :adapting for intensity in [0.3, 0.6)' do
      expect(described_class.state_for(0.5)).to eq(:adapting)
      expect(described_class.state_for(0.3)).to eq(:adapting)
    end

    it 'returns :residual for intensity in (MIN_INTENSITY, 0.3)' do
      expect(described_class.state_for(0.15)).to eq(:residual)
      expect(described_class.state_for(0.02)).to eq(:residual)
    end

    it 'returns :resolved for intensity at or below MIN_INTENSITY' do
      expect(described_class.state_for(0.01)).to eq(:resolved)
      expect(described_class.state_for(0.0)).to eq(:resolved)
    end
  end
end
