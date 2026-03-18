# frozen_string_literal: true

require 'legion/extensions/agentic/defense/confabulation/client'

RSpec.describe Legion::Extensions::Agentic::Defense::Confabulation::Client do
  let(:client) { described_class.new }

  it 'responds to confabulation runner methods' do
    expect(client).to respond_to(:register_claim)
    expect(client).to respond_to(:verify_claim)
    expect(client).to respond_to(:flag_confabulation)
    expect(client).to respond_to(:confabulation_report)
    expect(client).to respond_to(:high_risk_claims)
    expect(client).to respond_to(:confabulation_status)
  end

  it 'starts with an empty engine' do
    status = client.confabulation_status
    expect(status[:engine][:claim_count]).to eq(0)
  end

  it 'persists claims across calls within the same instance' do
    client.register_claim(content: 'persistent', claim_type: :factual,
                          confidence: 0.7, evidence_strength: 0.3)
    expect(client.confabulation_status[:engine][:claim_count]).to eq(1)
  end

  it 'maintains separate state between instances' do
    client.register_claim(content: 'instance A claim', claim_type: :factual,
                          confidence: 0.7, evidence_strength: 0.3)
    other = described_class.new
    expect(other.confabulation_status[:engine][:claim_count]).to eq(0)
  end
end
