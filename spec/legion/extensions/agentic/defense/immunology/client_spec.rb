# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Defense::Immunology::Client do
  let(:client) { described_class.new }

  it 'responds to detect_threat' do
    expect(client).to respond_to(:detect_threat)
  end

  it 'responds to quarantine_threat' do
    expect(client).to respond_to(:quarantine_threat)
  end

  it 'responds to release_threat' do
    expect(client).to respond_to(:release_threat)
  end

  it 'responds to inoculate' do
    expect(client).to respond_to(:inoculate)
  end

  it 'responds to create_antibody' do
    expect(client).to respond_to(:create_antibody)
  end

  it 'responds to scan_for_tactic' do
    expect(client).to respond_to(:scan_for_tactic)
  end

  it 'responds to trigger_inflammatory_response' do
    expect(client).to respond_to(:trigger_inflammatory_response)
  end

  it 'responds to resolve_inflammation' do
    expect(client).to respond_to(:resolve_inflammation)
  end

  it 'responds to overall_immunity' do
    expect(client).to respond_to(:overall_immunity)
  end

  it 'responds to vulnerability_report' do
    expect(client).to respond_to(:vulnerability_report)
  end

  it 'responds to threat_history' do
    expect(client).to respond_to(:threat_history)
  end

  it 'responds to decay_all' do
    expect(client).to respond_to(:decay_all)
  end

  it 'responds to prune_ineffective' do
    expect(client).to respond_to(:prune_ineffective)
  end

  it 'responds to immune_status' do
    expect(client).to respond_to(:immune_status)
  end
end
