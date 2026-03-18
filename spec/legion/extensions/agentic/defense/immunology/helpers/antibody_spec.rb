# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Defense::Immunology::Helpers::Antibody do
  subject(:antibody) { described_class.new(tactic: :authority_appeal, pattern: 'claimed expert status') }

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(antibody.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores tactic' do
      expect(antibody.tactic).to eq(:authority_appeal)
    end

    it 'stores pattern' do
      expect(antibody.pattern).to eq('claimed expert status')
    end

    it 'defaults strength to 0.5' do
      expect(antibody.strength).to eq(0.5)
    end

    it 'defaults matches to 0' do
      expect(antibody.matches).to eq(0)
    end

    it 'clamps strength above 1.0' do
      ab = described_class.new(tactic: :gaslighting, pattern: 'x', strength: 2.0)
      expect(ab.strength).to eq(1.0)
    end

    it 'clamps strength below 0.0' do
      ab = described_class.new(tactic: :gaslighting, pattern: 'x', strength: -1.0)
      expect(ab.strength).to eq(0.0)
    end
  end

  describe '#match!' do
    it 'increments matches' do
      antibody.match!
      expect(antibody.matches).to eq(1)
    end

    it 'boosts strength' do
      original = antibody.strength
      antibody.match!
      expect(antibody.strength).to be > original
    end

    it 'does not exceed 1.0' do
      ab = described_class.new(tactic: :gaslighting, pattern: 'x', strength: 1.0)
      ab.match!
      expect(ab.strength).to eq(1.0)
    end
  end

  describe '#decay!' do
    it 'reduces strength by RESISTANCE_DECAY' do
      original = antibody.strength
      antibody.decay!
      expect(antibody.strength).to be_within(0.001).of(original - Legion::Extensions::Agentic::Defense::Immunology::Helpers::Constants::RESISTANCE_DECAY)
    end

    it 'does not go below 0.0' do
      ab = described_class.new(tactic: :gaslighting, pattern: 'x', strength: 0.0)
      ab.decay!
      expect(ab.strength).to eq(0.0)
    end
  end

  describe '#effective?' do
    it 'returns true when strength >= 0.3' do
      expect(antibody.effective?).to be true
    end

    it 'returns false when strength < 0.3' do
      ab = described_class.new(tactic: :gaslighting, pattern: 'x', strength: 0.1)
      expect(ab.effective?).to be false
    end

    it 'returns true at exactly 0.3' do
      ab = described_class.new(tactic: :gaslighting, pattern: 'x', strength: 0.3)
      expect(ab.effective?).to be true
    end
  end

  describe '#to_h' do
    it 'returns a hash with all fields' do
      h = antibody.to_h
      expect(h).to include(:id, :tactic, :pattern, :strength, :matches, :effective, :created_at)
    end

    it 'includes effective status' do
      h = antibody.to_h
      expect(h[:effective]).to be true
    end
  end
end
