# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Defense::Confabulation::Helpers::Claim do
  let(:claim) do
    described_class.new(
      content:           'The sky is green',
      claim_type:        :factual,
      confidence:        0.8,
      evidence_strength: 0.3
    )
  end

  describe '#initialize' do
    it 'generates a UUID id' do
      expect(claim.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores content' do
      expect(claim.content).to eq('The sky is green')
    end

    it 'stores claim_type' do
      expect(claim.claim_type).to eq(:factual)
    end

    it 'clamps confidence to [0, 1]' do
      c = described_class.new(content: 'x', claim_type: :factual, confidence: 1.5, evidence_strength: 0.0)
      expect(c.confidence).to eq(1.0)
    end

    it 'clamps evidence_strength to [0, 1]' do
      c = described_class.new(content: 'x', claim_type: :factual, confidence: 0.5, evidence_strength: -0.5)
      expect(c.evidence_strength).to eq(0.0)
    end

    it 'starts unverified' do
      expect(claim.verified).to be false
    end

    it 'starts not confabulated' do
      expect(claim.confabulated).to be false
    end

    it 'sets created_at to utc time' do
      expect(claim.created_at).to be_a(Time)
    end
  end

  describe '#confabulation_risk' do
    it 'computes the gap between confidence and evidence_strength' do
      expect(claim.confabulation_risk).to be_within(0.001).of(0.5)
    end

    it 'clamps to 0.0 when evidence >= confidence' do
      c = described_class.new(content: 'x', claim_type: :factual, confidence: 0.3, evidence_strength: 0.9)
      expect(c.confabulation_risk).to eq(0.0)
    end

    it 'clamps to 1.0 when gap exceeds 1.0' do
      c = described_class.new(content: 'x', claim_type: :factual, confidence: 1.0, evidence_strength: 0.0)
      expect(c.confabulation_risk).to eq(1.0)
    end
  end

  describe '#verify!' do
    it 'marks the claim as verified' do
      claim.verify!
      expect(claim.verified).to be true
    end

    it 'returns self' do
      expect(claim.verify!).to eq(claim)
    end
  end

  describe '#mark_confabulated!' do
    it 'marks the claim as confabulated' do
      claim.mark_confabulated!
      expect(claim.confabulated).to be true
    end

    it 'returns self' do
      expect(claim.mark_confabulated!).to eq(claim)
    end
  end

  describe '#risk_label' do
    it 'returns :extreme for risk >= 0.8' do
      c = described_class.new(content: 'x', claim_type: :factual, confidence: 1.0, evidence_strength: 0.1)
      expect(c.risk_label).to eq(:extreme)
    end

    it 'returns :minimal for risk <= 0.2' do
      c = described_class.new(content: 'x', claim_type: :factual, confidence: 0.2, evidence_strength: 0.1)
      expect(c.risk_label).to eq(:minimal)
    end

    it 'returns :moderate for mid-range risk' do
      c = described_class.new(content: 'x', claim_type: :factual, confidence: 0.7, evidence_strength: 0.25)
      expect(c.risk_label).to eq(:moderate)
    end
  end

  describe '#to_h' do
    it 'includes all expected keys' do
      h = claim.to_h
      expect(h.keys).to include(
        :id, :content, :claim_type, :confidence, :evidence_strength,
        :confabulation_risk, :risk_label, :verified, :confabulated, :created_at
      )
    end

    it 'rounds numeric fields to 10 decimal places' do
      h = claim.to_h
      expect(h[:confidence]).to eq(0.8)
      expect(h[:confabulation_risk]).to be_a(Float)
    end
  end
end
