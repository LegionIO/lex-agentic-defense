# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Defense::Confabulation::Helpers::ConfabulationEngine do
  subject(:engine) { described_class.new }

  describe '#register_claim' do
    it 'stores the claim and returns a Claim object' do
      claim = engine.register_claim(content: 'Cats can fly', claim_type: :factual,
                                    confidence: 0.9, evidence_strength: 0.1)
      expect(claim).to be_a(Legion::Extensions::Agentic::Defense::Confabulation::Helpers::Claim)
      expect(engine.claims.size).to eq(1)
    end

    it 'assigns the claim an id' do
      claim = engine.register_claim(content: 'test', claim_type: :causal,
                                    confidence: 0.5, evidence_strength: 0.5)
      expect(claim.id).not_to be_nil
    end

    it 'defaults claim_type to :factual for unknown types' do
      claim = engine.register_claim(content: 'x', claim_type: :unknown,
                                    confidence: 0.5, evidence_strength: 0.5)
      expect(claim.claim_type).to eq(:factual)
    end

    it 'accepts all valid claim types' do
      Legion::Extensions::Agentic::Defense::Confabulation::Helpers::Constants::CLAIM_TYPES.each do |type|
        claim = engine.register_claim(content: 'x', claim_type: type,
                                      confidence: 0.5, evidence_strength: 0.5)
        expect(claim.claim_type).to eq(type)
      end
    end
  end

  describe '#verify_claim' do
    it 'marks claim as verified' do
      claim = engine.register_claim(content: 'x', claim_type: :factual,
                                    confidence: 0.5, evidence_strength: 0.5)
      result = engine.verify_claim(claim_id: claim.id)
      expect(result[:found]).to be true
      expect(result[:verified]).to be true
      expect(engine.claims[claim.id].verified).to be true
    end

    it 'returns found: false for unknown id' do
      result = engine.verify_claim(claim_id: 'no-such-id')
      expect(result[:found]).to be false
    end
  end

  describe '#flag_confabulation' do
    it 'marks claim as confabulated' do
      claim = engine.register_claim(content: 'x', claim_type: :factual,
                                    confidence: 0.9, evidence_strength: 0.1)
      result = engine.flag_confabulation(claim_id: claim.id)
      expect(result[:found]).to be true
      expect(result[:confabulated]).to be true
      expect(engine.claims[claim.id].confabulated).to be true
    end

    it 'returns found: false for unknown id' do
      result = engine.flag_confabulation(claim_id: 'no-such-id')
      expect(result[:found]).to be false
    end
  end

  describe '#high_risk_claims' do
    it 'returns claims above the confabulation threshold' do
      engine.register_claim(content: 'risky', claim_type: :factual, confidence: 0.9, evidence_strength: 0.1)
      engine.register_claim(content: 'safe',  claim_type: :factual, confidence: 0.4, evidence_strength: 0.4)
      high_risk = engine.high_risk_claims
      expect(high_risk.size).to eq(1)
      expect(high_risk.first.content).to eq('risky')
    end

    it 'returns empty array when no high-risk claims exist' do
      engine.register_claim(content: 'safe', claim_type: :factual, confidence: 0.3, evidence_strength: 0.3)
      expect(engine.high_risk_claims).to be_empty
    end
  end

  describe '#verified_claims' do
    it 'returns only verified claims' do
      c1 = engine.register_claim(content: 'verified', claim_type: :factual, confidence: 0.5, evidence_strength: 0.5)
      engine.register_claim(content: 'unverified', claim_type: :factual, confidence: 0.5, evidence_strength: 0.5)
      engine.verify_claim(claim_id: c1.id)
      expect(engine.verified_claims.size).to eq(1)
    end
  end

  describe '#confabulation_rate' do
    it 'returns 0.0 when no claims' do
      expect(engine.confabulation_rate).to eq(0.0)
    end

    it 'returns fraction of confabulated claims' do
      c1 = engine.register_claim(content: 'a', claim_type: :factual, confidence: 0.9, evidence_strength: 0.1)
      engine.register_claim(content: 'b', claim_type: :factual, confidence: 0.4, evidence_strength: 0.4)
      engine.flag_confabulation(claim_id: c1.id)
      expect(engine.confabulation_rate).to be_within(0.001).of(0.5)
    end
  end

  describe '#average_calibration' do
    it 'returns 0.0 when no claims' do
      expect(engine.average_calibration).to eq(0.0)
    end

    it 'returns 1.0 when all claims are perfectly calibrated' do
      engine.register_claim(content: 'x', claim_type: :factual, confidence: 0.5, evidence_strength: 0.5)
      expect(engine.average_calibration).to eq(1.0)
    end

    it 'returns lower value when confidence mismatches evidence' do
      engine.register_claim(content: 'x', claim_type: :factual, confidence: 1.0, evidence_strength: 0.0)
      expect(engine.average_calibration).to be < 1.0
    end
  end

  describe '#confabulation_report' do
    it 'returns a comprehensive report hash' do
      engine.register_claim(content: 'x', claim_type: :factual, confidence: 0.8, evidence_strength: 0.2)
      report = engine.confabulation_report
      expect(report.keys).to include(
        :total_claims, :high_risk_claims, :verified_claims,
        :confabulated_claims, :confabulation_rate, :average_calibration,
        :overall_risk, :risk_label
      )
    end

    it 'risk_label is a symbol' do
      report = engine.confabulation_report
      expect(report[:risk_label]).to be_a(Symbol)
    end

    it 'totals match registered claims' do
      2.times { |i| engine.register_claim(content: "claim#{i}", claim_type: :factual, confidence: 0.5, evidence_strength: 0.5) }
      expect(engine.confabulation_report[:total_claims]).to eq(2)
    end
  end

  describe '#prune_if_needed' do
    it 'prunes oldest claim when at MAX_CLAIMS capacity' do
      max = Legion::Extensions::Agentic::Defense::Confabulation::Helpers::Constants::MAX_CLAIMS
      first_claim = engine.register_claim(content: 'first', claim_type: :factual, confidence: 0.5, evidence_strength: 0.5)
      (max - 1).times { |i| engine.register_claim(content: "claim#{i}", claim_type: :factual, confidence: 0.5, evidence_strength: 0.5) }
      expect(engine.claims.size).to eq(max)
      engine.register_claim(content: 'overflow', claim_type: :factual, confidence: 0.5, evidence_strength: 0.5)
      expect(engine.claims.size).to eq(max)
      expect(engine.claims[first_claim.id]).to be_nil
    end
  end

  describe '#to_h' do
    it 'returns a summary hash' do
      engine.register_claim(content: 'x', claim_type: :factual, confidence: 0.5, evidence_strength: 0.5)
      h = engine.to_h
      expect(h).to have_key(:claim_count)
      expect(h).to have_key(:confabulation_rate)
      expect(h).to have_key(:average_calibration)
    end
  end
end
