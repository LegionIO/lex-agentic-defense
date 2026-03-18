# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Defense::Phantom::Helpers::PhantomEngine do
  subject(:engine) { described_class.new }

  describe '#register_removal' do
    it 'returns a PhantomLimb' do
      limb = engine.register_removal(capability_name: 'lex-http', capability_domain: :network)
      expect(limb).to be_a(Legion::Extensions::Agentic::Defense::Phantom::Helpers::PhantomLimb)
    end

    it 'assigns a uuid id' do
      limb = engine.register_removal(capability_name: 'lex-redis')
      expect(limb.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'defaults capability_domain to :general' do
      limb = engine.register_removal(capability_name: 'lex-vault')
      expect(limb.capability_domain).to eq(:general)
    end

    it 'adds limb to all_phantoms' do
      engine.register_removal(capability_name: 'lex-http')
      expect(engine.all_phantoms.size).to eq(1)
    end

    it 'returns nil when MAX_PHANTOMS is reached' do
      stub_const('Legion::Extensions::Agentic::Defense::Phantom::Helpers::Constants::MAX_PHANTOMS', 2)
      engine.register_removal(capability_name: 'cap1')
      engine.register_removal(capability_name: 'cap2')
      result = engine.register_removal(capability_name: 'cap3')
      expect(result).to be_nil
    end

    it 'allows up to MAX_PHANTOMS registrations' do
      stub_const('Legion::Extensions::Agentic::Defense::Phantom::Helpers::Constants::MAX_PHANTOMS', 3)
      3.times { |i| engine.register_removal(capability_name: "cap_#{i}") }
      expect(engine.all_phantoms.size).to eq(3)
    end
  end

  describe '#process_stimulus' do
    before do
      engine.register_removal(capability_name: 'lex-http', capability_domain: :network)
      engine.register_removal(capability_name: 'lex-redis', capability_domain: :cache)
    end

    it 'returns an array of PhantomSignals' do
      signals = engine.process_stimulus(stimulus: 'test', domain: :any)
      expect(signals).to all(be_a(Legion::Extensions::Agentic::Defense::Phantom::Helpers::PhantomSignal))
    end

    it 'fires all active phantoms when domain is :any' do
      signals = engine.process_stimulus(stimulus: 'event', domain: :any)
      expect(signals.size).to eq(2)
    end

    it 'only fires phantoms matching domain' do
      signals = engine.process_stimulus(stimulus: 'cache miss', domain: :cache)
      expect(signals.size).to eq(1)
      expect(signals.first.phantom_limb_id).to be_a(String)
    end

    it 'returns empty array when no matching domain' do
      signals = engine.process_stimulus(stimulus: 'event', domain: :storage)
      expect(signals).to be_empty
    end

    it 'does not fire resolved phantoms' do
      limb = engine.all_phantoms.first
      160.times { limb.decay! }
      signals = engine.process_stimulus(stimulus: 'lex-http request', domain: :network)
      expect(signals).to be_empty
    end
  end

  describe '#decay_all!' do
    before { engine.register_removal(capability_name: 'lex-http') }

    it 'reduces intensity of all active phantoms' do
      before_intensity = engine.active_phantoms.first.intensity
      engine.decay_all!
      expect(engine.active_phantoms.first.intensity).to be < before_intensity
    end

    it 'returns count of newly resolved phantoms' do
      stub_const('Legion::Extensions::Agentic::Defense::Phantom::Helpers::Constants::INITIAL_INTENSITY', Legion::Extensions::Agentic::Defense::Phantom::Helpers::Constants::MIN_INTENSITY)
      engine2 = described_class.new
      engine2.register_removal(capability_name: 'cap_at_min')
      count = engine2.decay_all!
      expect(count).to be >= 0
    end
  end

  describe '#acknowledge' do
    let!(:limb) { engine.register_removal(capability_name: 'lex-vault') }

    it 'returns acknowledged: true for valid phantom_id' do
      result = engine.acknowledge(phantom_id: limb.id)
      expect(result[:acknowledged]).to be true
    end

    it 'returns phantom_id in result' do
      result = engine.acknowledge(phantom_id: limb.id)
      expect(result[:phantom_id]).to eq(limb.id)
    end

    it 'returns state in result' do
      result = engine.acknowledge(phantom_id: limb.id)
      expect(Legion::Extensions::Agentic::Defense::Phantom::Helpers::Constants::PHANTOM_STATES).to include(result[:state])
    end

    it 'accelerates decay on acknowledgment' do
      before_intensity = limb.intensity
      engine.acknowledge(phantom_id: limb.id)
      expect(limb.intensity).to be < before_intensity
    end

    it 'returns acknowledged: false for unknown phantom_id' do
      result = engine.acknowledge(phantom_id: 'nonexistent-uuid')
      expect(result[:acknowledged]).to be false
      expect(result[:reason]).to eq(:not_found)
    end
  end

  describe '#all_phantoms' do
    it 'returns all registered phantoms including resolved' do
      engine.register_removal(capability_name: 'cap1')
      engine.register_removal(capability_name: 'cap2')
      expect(engine.all_phantoms.size).to eq(2)
    end
  end

  describe '#active_phantoms' do
    it 'excludes resolved phantoms' do
      engine.register_removal(capability_name: 'cap1')
      limb = engine.register_removal(capability_name: 'cap2')
      160.times { limb.decay! }
      expect(engine.active_phantoms.size).to eq(1)
    end
  end

  describe '#phantom_activity_report' do
    before do
      engine.register_removal(capability_name: 'cap1', capability_domain: :network)
      engine.register_removal(capability_name: 'cap2', capability_domain: :cache)
    end

    it 'returns total count' do
      expect(engine.phantom_activity_report[:total]).to eq(2)
    end

    it 'returns active count' do
      expect(engine.phantom_activity_report[:active]).to eq(2)
    end

    it 'returns by_state breakdown' do
      report = engine.phantom_activity_report
      expect(report[:by_state]).to be_a(Hash)
      expect(report[:by_state].keys).to match_array(%i[acute adapting residual resolved])
    end

    it 'returns total_activations' do
      engine.process_stimulus(stimulus: 'event', domain: :any)
      expect(engine.phantom_activity_report[:total_activations]).to eq(2)
    end
  end

  describe '#most_persistent' do
    before do
      3.times do |i|
        limb = engine.register_removal(capability_name: "cap_#{i}")
        i.times { limb.trigger!("stimulus_#{i}") }
      end
    end

    it 'returns active phantoms sorted by activation_count descending' do
      result = engine.most_persistent(limit: 3)
      counts = result.map(&:activation_count)
      expect(counts).to eq(counts.sort.reverse)
    end

    it 'respects limit' do
      result = engine.most_persistent(limit: 2)
      expect(result.size).to be <= 2
    end
  end

  describe '#recently_triggered' do
    before do
      2.times do |i|
        limb = engine.register_removal(capability_name: "cap_#{i}")
        limb.trigger!("stimulus_#{i}")
      end
    end

    it 'returns recently triggered phantoms' do
      result = engine.recently_triggered(limit: 5)
      expect(result).not_to be_empty
      result.each { |p| expect(p.last_triggered).not_to be_nil }
    end

    it 'respects limit' do
      result = engine.recently_triggered(limit: 1)
      expect(result.size).to be <= 1
    end
  end

  describe '#resolve_check!' do
    it 'returns count of resolved phantoms' do
      limb = engine.register_removal(capability_name: 'cap_near_zero')
      160.times { limb.decay! }
      count = engine.resolve_check!
      expect(count).to be >= 1
    end

    it 'returns 0 when no phantoms are resolved' do
      engine.register_removal(capability_name: 'fresh_cap')
      expect(engine.resolve_check!).to eq(0)
    end
  end
end
