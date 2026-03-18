# frozen_string_literal: true

require 'legion/extensions/agentic/defense/confabulation/client'

RSpec.describe Legion::Extensions::Agentic::Defense::Confabulation::Runners::Confabulation do
  let(:client) { Legion::Extensions::Agentic::Defense::Confabulation::Client.new }

  describe '#register_claim' do
    it 'returns a claim hash with an id' do
      result = client.register_claim(content: 'Pigeons navigate by smell', claim_type: :factual,
                                     confidence: 0.7, evidence_strength: 0.2)
      expect(result[:id]).not_to be_nil
      expect(result[:claim_type]).to eq(:factual)
    end

    it 'includes confabulation_risk and risk_label' do
      result = client.register_claim(content: 'x', claim_type: :causal, confidence: 0.9, evidence_strength: 0.1)
      expect(result).to have_key(:confabulation_risk)
      expect(result).to have_key(:risk_label)
    end

    it 'accepts all valid claim types' do
      Legion::Extensions::Agentic::Defense::Confabulation::Helpers::Constants::CLAIM_TYPES.each do |type|
        result = client.register_claim(content: 'x', claim_type: type, confidence: 0.5, evidence_strength: 0.5)
        expect(result[:claim_type]).to eq(type)
      end
    end
  end

  describe '#verify_claim' do
    it 'verifies an existing claim' do
      claim = client.register_claim(content: 'testable fact', claim_type: :factual,
                                    confidence: 0.6, evidence_strength: 0.6)
      result = client.verify_claim(claim_id: claim[:id])
      expect(result[:found]).to be true
      expect(result[:verified]).to be true
    end

    it 'returns found: false for a missing claim' do
      result = client.verify_claim(claim_id: 'does-not-exist')
      expect(result[:found]).to be false
    end
  end

  describe '#flag_confabulation' do
    it 'flags an existing claim as confabulated' do
      claim = client.register_claim(content: 'false memory', claim_type: :autobiographical,
                                    confidence: 0.9, evidence_strength: 0.05)
      result = client.flag_confabulation(claim_id: claim[:id])
      expect(result[:found]).to be true
      expect(result[:confabulated]).to be true
    end

    it 'returns found: false for a missing claim' do
      result = client.flag_confabulation(claim_id: 'no-such-id')
      expect(result[:found]).to be false
    end
  end

  describe '#confabulation_report' do
    it 'returns a report hash' do
      client.register_claim(content: 'risky', claim_type: :factual, confidence: 0.9, evidence_strength: 0.05)
      report = client.confabulation_report
      expect(report[:total_claims]).to eq(1)
      expect(report[:risk_label]).to be_a(Symbol)
    end

    it 'includes overall_risk and average_calibration' do
      report = client.confabulation_report
      expect(report).to have_key(:overall_risk)
      expect(report).to have_key(:average_calibration)
    end
  end

  describe '#high_risk_claims' do
    it 'returns claims above the threshold' do
      client.register_claim(content: 'overconfident', claim_type: :predictive,
                            confidence: 0.95, evidence_strength: 0.05)
      client.register_claim(content: 'calibrated', claim_type: :predictive,
                            confidence: 0.5, evidence_strength: 0.5)
      result = client.high_risk_claims
      expect(result[:count]).to eq(1)
      expect(result[:claims].first[:content]).to eq('overconfident')
    end

    it 'returns empty list when no high-risk claims' do
      client.register_claim(content: 'ok', claim_type: :factual, confidence: 0.5, evidence_strength: 0.5)
      result = client.high_risk_claims
      expect(result[:count]).to eq(0)
    end
  end

  describe '#confabulation_status' do
    it 'returns engine summary' do
      result = client.confabulation_status
      expect(result[:engine]).to have_key(:claim_count)
      expect(result[:engine]).to have_key(:confabulation_rate)
      expect(result[:engine]).to have_key(:average_calibration)
    end
  end

  describe 'full cycle' do
    it 'registers, verifies, flags and reports correctly' do
      c1 = client.register_claim(content: 'valid fact', claim_type: :factual,
                                 confidence: 0.6, evidence_strength: 0.6)
      c2 = client.register_claim(content: 'false memory', claim_type: :autobiographical,
                                 confidence: 0.9, evidence_strength: 0.05)

      client.verify_claim(claim_id: c1[:id])
      client.flag_confabulation(claim_id: c2[:id])

      report = client.confabulation_report
      expect(report[:total_claims]).to eq(2)
      expect(report[:verified_claims]).to eq(1)
      expect(report[:confabulated_claims]).to eq(1)
      expect(report[:confabulation_rate]).to be_within(0.001).of(0.5)
    end
  end
end
