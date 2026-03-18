# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Defense::Immunology::Helpers::Threat do
  subject(:threat) { described_class.new(source: 'test', tactic: :gaslighting, content_hash: 'abc123') }

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(threat.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores source' do
      expect(threat.source).to eq('test')
    end

    it 'stores tactic' do
      expect(threat.tactic).to eq(:gaslighting)
    end

    it 'stores content_hash' do
      expect(threat.content_hash).to eq('abc123')
    end

    it 'defaults threat_level to 0.5' do
      expect(threat.threat_level).to eq(0.5)
    end

    it 'defaults quarantined to false' do
      expect(threat.quarantined).to be false
    end

    it 'defaults exposure_count to 0' do
      expect(threat.exposure_count).to eq(0)
    end

    it 'clamps threat_level above 1.0' do
      t = described_class.new(source: 's', tactic: :strawman, content_hash: 'x', threat_level: 1.5)
      expect(t.threat_level).to eq(1.0)
    end

    it 'clamps threat_level below 0.0' do
      t = described_class.new(source: 's', tactic: :strawman, content_hash: 'x', threat_level: -0.5)
      expect(t.threat_level).to eq(0.0)
    end
  end

  describe '#threat_label' do
    it 'returns :critical for 0.9' do
      t = described_class.new(source: 's', tactic: :gaslighting, content_hash: 'x', threat_level: 0.9)
      expect(t.threat_label).to eq(:critical)
    end

    it 'returns :moderate for 0.5' do
      expect(threat.threat_label).to eq(:moderate)
    end

    it 'returns :negligible for 0.1' do
      t = described_class.new(source: 's', tactic: :gaslighting, content_hash: 'x', threat_level: 0.1)
      expect(t.threat_label).to eq(:negligible)
    end
  end

  describe '#quarantine!' do
    it 'sets quarantined to true' do
      threat.quarantine!
      expect(threat.quarantined).to be true
    end
  end

  describe '#release!' do
    it 'sets quarantined back to false' do
      threat.quarantine!
      threat.release!
      expect(threat.quarantined).to be false
    end
  end

  describe '#expose!' do
    it 'increments exposure_count' do
      threat.expose!
      expect(threat.exposure_count).to eq(1)
    end

    it 'reduces threat_level (inoculation effect)' do
      original = threat.threat_level
      threat.expose!
      expect(threat.threat_level).to be < original
    end

    it 'does not drop threat_level below 0.0' do
      t = described_class.new(source: 's', tactic: :gaslighting, content_hash: 'x', threat_level: 0.0)
      t.expose!
      expect(t.threat_level).to eq(0.0)
    end

    it 'diminishing reduction on repeated exposure' do
      first_level = threat.threat_level
      threat.expose!
      reduction1 = first_level - threat.threat_level

      second_level = threat.threat_level
      threat.expose!
      reduction2 = second_level - threat.threat_level

      expect(reduction2).to be <= reduction1
    end
  end

  describe '#escalate!' do
    it 'increases threat_level by default 0.1' do
      original = threat.threat_level
      threat.escalate!
      expect(threat.threat_level).to be_within(0.001).of(original + 0.1)
    end

    it 'respects custom amount' do
      threat.escalate!(amount: 0.2)
      expect(threat.threat_level).to be_within(0.001).of(0.7)
    end

    it 'does not exceed 1.0' do
      t = described_class.new(source: 's', tactic: :gaslighting, content_hash: 'x', threat_level: 0.95)
      t.escalate!(amount: 0.5)
      expect(t.threat_level).to eq(1.0)
    end
  end

  describe '#to_h' do
    it 'returns a hash with all fields' do
      h = threat.to_h
      expect(h).to include(:id, :source, :tactic, :content_hash, :threat_level, :threat_label, :quarantined, :exposure_count, :created_at)
    end
  end
end
