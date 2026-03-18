# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Defense::Immunology::Helpers::ImmuneEngine do
  subject(:engine) { described_class.new }

  describe '#initialize' do
    it 'starts with DEFAULT_RESISTANCE' do
      expect(engine.resistance).to eq(Legion::Extensions::Agentic::Defense::Immunology::Helpers::Constants::DEFAULT_RESISTANCE)
    end

    it 'starts with inflammatory false' do
      expect(engine.inflammatory).to be false
    end
  end

  describe '#detect_threat' do
    it 'returns a Threat object' do
      threat = engine.detect_threat(source: 'user', tactic: :gaslighting, content_hash: 'h1')
      expect(threat).to be_a(Legion::Extensions::Agentic::Defense::Immunology::Helpers::Threat)
    end

    it 'stores the threat' do
      threat = engine.detect_threat(source: 'user', tactic: :strawman, content_hash: 'h2')
      expect(engine.to_h[:threat_count]).to eq(1)
      expect(threat.id).not_to be_nil
    end

    it 'applies antibody resistance to threat_level' do
      engine.create_antibody(tactic: :authority_appeal, pattern: 'expert claim', strength: 0.8)
      threat = engine.detect_threat(source: 'src', tactic: :authority_appeal, content_hash: 'h3', threat_level: 0.8)
      expect(threat.threat_level).to be < 0.8
    end

    it 'tracks multiple threats' do
      engine.detect_threat(source: 's1', tactic: :gaslighting, content_hash: 'a')
      engine.detect_threat(source: 's2', tactic: :strawman, content_hash: 'b')
      expect(engine.to_h[:threat_count]).to eq(2)
    end
  end

  describe '#quarantine_threat' do
    let(:threat) { engine.detect_threat(source: 'src', tactic: :gaslighting, content_hash: 'h1') }

    it 'quarantines an existing threat' do
      result = engine.quarantine_threat(threat_id: threat.id)
      expect(result[:success]).to be true
      expect(threat.quarantined).to be true
    end

    it 'returns failure for unknown threat_id' do
      result = engine.quarantine_threat(threat_id: 'nonexistent')
      expect(result[:success]).to be false
    end

    it 'increments quarantined_count' do
      engine.quarantine_threat(threat_id: threat.id)
      expect(engine.to_h[:quarantined_count]).to eq(1)
    end
  end

  describe '#release_threat' do
    let(:threat) { engine.detect_threat(source: 'src', tactic: :gaslighting, content_hash: 'h1') }

    it 'releases a quarantined threat' do
      engine.quarantine_threat(threat_id: threat.id)
      result = engine.release_threat(threat_id: threat.id)
      expect(result[:success]).to be true
      expect(threat.quarantined).to be false
    end

    it 'returns failure for unknown threat_id' do
      result = engine.release_threat(threat_id: 'nonexistent')
      expect(result[:success]).to be false
    end
  end

  describe '#inoculate' do
    let(:threat) { engine.detect_threat(source: 'src', tactic: :gaslighting, content_hash: 'h1') }

    it 'returns success for existing threat' do
      result = engine.inoculate(threat_id: threat.id)
      expect(result[:success]).to be true
    end

    it 'increments exposure_count on the threat' do
      engine.inoculate(threat_id: threat.id)
      expect(threat.exposure_count).to eq(1)
    end

    it 'boosts overall resistance' do
      original = engine.resistance
      engine.inoculate(threat_id: threat.id)
      expect(engine.resistance).to be > original
    end

    it 'returns failure for unknown threat_id' do
      result = engine.inoculate(threat_id: 'nonexistent')
      expect(result[:success]).to be false
    end
  end

  describe '#create_antibody' do
    it 'returns an Antibody object' do
      ab = engine.create_antibody(tactic: :gaslighting, pattern: 'reality questioning')
      expect(ab).to be_a(Legion::Extensions::Agentic::Defense::Immunology::Helpers::Antibody)
    end

    it 'stores the antibody' do
      engine.create_antibody(tactic: :strawman, pattern: 'misrepresentation')
      expect(engine.to_h[:antibody_count]).to eq(1)
    end

    it 'accepts custom strength' do
      ab = engine.create_antibody(tactic: :gaslighting, pattern: 'test', strength: 0.8)
      expect(ab.strength).to eq(0.8)
    end
  end

  describe '#scan_for_tactic' do
    before do
      engine.detect_threat(source: 's1', tactic: :gaslighting, content_hash: 'h1')
      engine.detect_threat(source: 's2', tactic: :gaslighting, content_hash: 'h2')
      engine.detect_threat(source: 's3', tactic: :strawman, content_hash: 'h3')
    end

    it 'returns threats matching the tactic' do
      threats = engine.scan_for_tactic(tactic: :gaslighting)
      expect(threats.size).to eq(2)
      expect(threats.all? { |t| t.tactic == :gaslighting }).to be true
    end

    it 'returns empty array for unknown tactic' do
      threats = engine.scan_for_tactic(tactic: :bandwagon)
      expect(threats).to be_empty
    end
  end

  describe '#trigger_inflammatory_response' do
    it 'sets inflammatory to true' do
      engine.trigger_inflammatory_response
      expect(engine.inflammatory).to be true
    end

    it 'returns inflammatory: true' do
      result = engine.trigger_inflammatory_response
      expect(result[:inflammatory]).to be true
    end
  end

  describe '#resolve_inflammation' do
    before { engine.trigger_inflammatory_response }

    it 'sets inflammatory to false' do
      engine.resolve_inflammation
      expect(engine.inflammatory).to be false
    end

    it 'returns inflammatory: false' do
      result = engine.resolve_inflammation
      expect(result[:inflammatory]).to be false
    end
  end

  describe '#overall_immunity' do
    it 'returns a float between 0.0 and 1.0' do
      score = engine.overall_immunity
      expect(score).to be_between(0.0, 1.0)
    end

    it 'increases with more effective antibodies' do
      base = engine.overall_immunity
      engine.create_antibody(tactic: :gaslighting, pattern: 'test', strength: 0.9)
      engine.create_antibody(tactic: :strawman, pattern: 'test2', strength: 0.9)
      expect(engine.overall_immunity).to be > base
    end
  end

  describe '#immunity_label' do
    it 'returns a symbol' do
      expect(engine.immunity_label).to be_a(Symbol)
    end

    it 'returns :normal at default resistance with no antibodies' do
      label = engine.immunity_label
      expect(%i[normal vulnerable]).to include(label)
    end
  end

  describe '#vulnerability_report' do
    it 'returns covered, uncovered, and coverage' do
      report = engine.vulnerability_report
      expect(report).to include(:covered, :uncovered, :coverage)
    end

    it 'starts fully uncovered' do
      report = engine.vulnerability_report
      expect(report[:uncovered].size).to eq(Legion::Extensions::Agentic::Defense::Immunology::Helpers::Constants::MANIPULATION_TACTICS.size)
    end

    it 'reduces uncovered after creating an antibody' do
      engine.create_antibody(tactic: :gaslighting, pattern: 'test')
      report = engine.vulnerability_report
      expect(report[:uncovered]).not_to include(:gaslighting)
    end
  end

  describe '#threat_history' do
    before do
      5.times { |i| engine.detect_threat(source: "s#{i}", tactic: :gaslighting, content_hash: "h#{i}") }
    end

    it 'returns up to limit threats' do
      history = engine.threat_history(limit: 3)
      expect(history.size).to eq(3)
    end

    it 'returns hashes' do
      history = engine.threat_history
      expect(history.first).to be_a(Hash)
    end

    it 'defaults to limit 10' do
      history = engine.threat_history
      expect(history.size).to be <= 10
    end
  end

  describe '#decay_all' do
    it 'decays antibodies' do
      ab = engine.create_antibody(tactic: :gaslighting, pattern: 'test', strength: 0.5)
      original_strength = ab.strength
      engine.decay_all
      expect(ab.strength).to be < original_strength
    end

    it 'decays overall resistance' do
      original = engine.resistance
      engine.decay_all
      expect(engine.resistance).to be < original
    end

    it 'returns resistance and antibodies_decayed' do
      engine.create_antibody(tactic: :gaslighting, pattern: 'test')
      result = engine.decay_all
      expect(result).to include(:resistance, :antibodies_decayed)
    end
  end

  describe '#prune_ineffective' do
    it 'removes antibodies below effective threshold' do
      engine.create_antibody(tactic: :gaslighting, pattern: 'strong', strength: 0.8)
      engine.create_antibody(tactic: :strawman, pattern: 'weak', strength: 0.1)
      result = engine.prune_ineffective
      expect(result[:pruned]).to eq(1)
      expect(result[:remaining]).to eq(1)
    end

    it 'returns 0 pruned when all are effective' do
      engine.create_antibody(tactic: :gaslighting, pattern: 'strong', strength: 0.8)
      result = engine.prune_ineffective
      expect(result[:pruned]).to eq(0)
    end
  end

  describe '#to_h' do
    it 'returns engine stats as hash' do
      h = engine.to_h
      expect(h).to include(
        :threat_count, :quarantined_count, :antibody_count,
        :effective_antibody_count, :resistance, :inflammatory,
        :overall_immunity, :immunity_label
      )
    end
  end
end
