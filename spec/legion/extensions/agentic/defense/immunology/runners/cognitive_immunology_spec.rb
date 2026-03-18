# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Defense::Immunology::Runners::CognitiveImmunology do
  let(:client) { Legion::Extensions::Agentic::Defense::Immunology::Client.new }

  describe '#detect_threat' do
    it 'returns success true with threat data' do
      result = client.detect_threat(source: 'test', tactic: :gaslighting, content_hash: 'h1')
      expect(result[:success]).to be true
      expect(result[:threat]).to include(:id, :tactic, :threat_level)
    end

    it 'uses custom threat_level' do
      result = client.detect_threat(source: 'src', tactic: :strawman, content_hash: 'h2', threat_level: 0.9)
      expect(result[:threat][:threat_level]).to be_within(0.01).of(0.9)
    end
  end

  describe '#quarantine_threat' do
    let(:threat_id) do
      client.detect_threat(source: 'src', tactic: :gaslighting, content_hash: 'h1')[:threat][:id]
    end

    it 'quarantines an existing threat' do
      result = client.quarantine_threat(threat_id: threat_id)
      expect(result[:success]).to be true
    end

    it 'fails for unknown id' do
      result = client.quarantine_threat(threat_id: 'unknown')
      expect(result[:success]).to be false
    end
  end

  describe '#release_threat' do
    let(:threat_id) do
      id = client.detect_threat(source: 'src', tactic: :gaslighting, content_hash: 'h1')[:threat][:id]
      client.quarantine_threat(threat_id: id)
      id
    end

    it 'releases a quarantined threat' do
      result = client.release_threat(threat_id: threat_id)
      expect(result[:success]).to be true
    end
  end

  describe '#inoculate' do
    let(:threat_id) do
      client.detect_threat(source: 'src', tactic: :gaslighting, content_hash: 'h1')[:threat][:id]
    end

    it 'returns success and exposure_count' do
      result = client.inoculate(threat_id: threat_id)
      expect(result[:success]).to be true
      expect(result[:exposure_count]).to eq(1)
    end

    it 'boosts resistance' do
      before_status = client.immune_status
      client.inoculate(threat_id: threat_id)
      after_status = client.immune_status
      expect(after_status[:resistance]).to be >= before_status[:resistance]
    end

    it 'fails for unknown threat' do
      result = client.inoculate(threat_id: 'nope')
      expect(result[:success]).to be false
    end
  end

  describe '#create_antibody' do
    it 'returns success with antibody data' do
      result = client.create_antibody(tactic: :authority_appeal, pattern: 'expert claim')
      expect(result[:success]).to be true
      expect(result[:antibody]).to include(:id, :tactic, :strength)
    end

    it 'accepts custom strength' do
      result = client.create_antibody(tactic: :gaslighting, pattern: 'test', strength: 0.7)
      expect(result[:antibody][:strength]).to eq(0.7)
    end
  end

  describe '#scan_for_tactic' do
    before do
      client.detect_threat(source: 's1', tactic: :strawman, content_hash: 'h1')
      client.detect_threat(source: 's2', tactic: :strawman, content_hash: 'h2')
    end

    it 'returns threats for matching tactic' do
      result = client.scan_for_tactic(tactic: :strawman)
      expect(result[:success]).to be true
      expect(result[:count]).to eq(2)
    end

    it 'returns empty for unmatched tactic' do
      result = client.scan_for_tactic(tactic: :bandwagon)
      expect(result[:count]).to eq(0)
    end
  end

  describe '#trigger_inflammatory_response' do
    it 'activates inflammatory mode' do
      result = client.trigger_inflammatory_response
      expect(result[:success]).to be true
      expect(result[:inflammatory]).to be true
    end
  end

  describe '#resolve_inflammation' do
    before { client.trigger_inflammatory_response }

    it 'deactivates inflammatory mode' do
      result = client.resolve_inflammation
      expect(result[:success]).to be true
      expect(result[:inflammatory]).to be false
    end
  end

  describe '#overall_immunity' do
    it 'returns score and label' do
      result = client.overall_immunity
      expect(result[:success]).to be true
      expect(result[:score]).to be_between(0.0, 1.0)
      expect(result[:label]).to be_a(Symbol)
    end
  end

  describe '#vulnerability_report' do
    it 'returns coverage info' do
      result = client.vulnerability_report
      expect(result[:success]).to be true
      expect(result).to include(:covered, :uncovered, :coverage)
    end
  end

  describe '#threat_history' do
    before { 3.times { |i| client.detect_threat(source: "s#{i}", tactic: :gaslighting, content_hash: "h#{i}") } }

    it 'returns threats list' do
      result = client.threat_history
      expect(result[:success]).to be true
      expect(result[:count]).to eq(3)
    end

    it 'respects limit' do
      result = client.threat_history(limit: 2)
      expect(result[:count]).to eq(2)
    end
  end

  describe '#decay_all' do
    it 'returns success with resistance' do
      result = client.decay_all
      expect(result[:success]).to be true
      expect(result).to include(:resistance)
    end
  end

  describe '#prune_ineffective' do
    it 'returns pruned and remaining counts' do
      client.create_antibody(tactic: :gaslighting, pattern: 'weak', strength: 0.1)
      result = client.prune_ineffective
      expect(result[:success]).to be true
      expect(result[:pruned]).to eq(1)
    end
  end

  describe '#immune_status' do
    it 'returns full engine stats' do
      result = client.immune_status
      expect(result[:success]).to be true
      expect(result).to include(:threat_count, :antibody_count, :resistance, :inflammatory)
    end
  end
end
