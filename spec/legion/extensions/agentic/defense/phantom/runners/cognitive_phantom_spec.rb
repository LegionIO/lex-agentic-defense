# frozen_string_literal: true

require 'legion/extensions/agentic/defense/phantom/client'

RSpec.describe Legion::Extensions::Agentic::Defense::Phantom::Runners::CognitivePhantom do
  let(:client) { Legion::Extensions::Agentic::Defense::Phantom::Client.new }

  describe '#register_removal' do
    it 'returns success: true with valid params' do
      result = client.register_removal(capability_name: 'lex-http', capability_domain: :network)
      expect(result[:success]).to be true
    end

    it 'returns a phantom_id uuid' do
      result = client.register_removal(capability_name: 'lex-http')
      expect(result[:phantom_id]).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'returns capability_name in result' do
      result = client.register_removal(capability_name: 'lex-redis')
      expect(result[:capability_name]).to eq('lex-redis')
    end

    it 'returns state in result' do
      result = client.register_removal(capability_name: 'lex-vault')
      expect(Legion::Extensions::Agentic::Defense::Phantom::Helpers::Constants::PHANTOM_STATES).to include(result[:state])
    end

    it 'returns intensity in result' do
      result = client.register_removal(capability_name: 'lex-consul')
      expect(result[:intensity]).to be_a(Float)
      expect(result[:intensity]).to be_between(0.0, 1.0)
    end

    it 'returns success: false for empty capability_name' do
      result = client.register_removal(capability_name: '')
      expect(result[:success]).to be false
      expect(result[:error]).to be_a(String)
    end

    it 'uses injected engine when provided' do
      eng    = Legion::Extensions::Agentic::Defense::Phantom::Helpers::PhantomEngine.new
      result = client.register_removal(capability_name: 'lex-ssh', engine: eng)
      expect(result[:success]).to be true
      expect(eng.all_phantoms.size).to eq(1)
    end

    it 'defaults capability_domain to :general' do
      result = client.register_removal(capability_name: 'lex-smtp')
      expect(result[:success]).to be true
    end
  end

  describe '#process_stimulus' do
    before { client.register_removal(capability_name: 'lex-http', capability_domain: :network) }

    it 'returns success: true' do
      result = client.process_stimulus(stimulus: 'http.get fired')
      expect(result[:success]).to be true
    end

    it 'returns fired_count' do
      result = client.process_stimulus(stimulus: 'event', domain: :any)
      expect(result[:fired_count]).to be >= 1
    end

    it 'returns signals array' do
      result = client.process_stimulus(stimulus: 'event', domain: :any)
      expect(result[:signals]).to be_an(Array)
    end

    it 'signals contain expected keys' do
      result = client.process_stimulus(stimulus: 'event', domain: :any)
      expect(result[:signals].first).to include(:id, :phantom_limb_id, :trigger_type, :intensity_at_trigger)
    end

    it 'returns domain in result' do
      result = client.process_stimulus(stimulus: 'event', domain: :network)
      expect(result[:domain]).to eq(:network)
    end

    it 'returns success: false when stimulus is nil' do
      result = client.process_stimulus(stimulus: nil)
      expect(result[:success]).to be false
    end

    it 'uses injected engine' do
      eng = Legion::Extensions::Agentic::Defense::Phantom::Helpers::PhantomEngine.new
      eng.register_removal(capability_name: 'injected-cap')
      result = client.process_stimulus(stimulus: 'event', domain: :any, engine: eng)
      expect(result[:fired_count]).to eq(1)
    end
  end

  describe '#acknowledge_phantom' do
    let(:phantom_id) do
      client.register_removal(capability_name: 'lex-github')[:phantom_id]
    end

    it 'returns success: true for valid phantom_id' do
      result = client.acknowledge_phantom(phantom_id: phantom_id)
      expect(result[:success]).to be true
    end

    it 'returns acknowledged: true for valid phantom_id' do
      result = client.acknowledge_phantom(phantom_id: phantom_id)
      expect(result[:acknowledged]).to be true
    end

    it 'returns success: false for unknown phantom_id' do
      result = client.acknowledge_phantom(phantom_id: SecureRandom.uuid)
      expect(result[:success]).to be false
    end

    it 'returns success: false for empty phantom_id' do
      result = client.acknowledge_phantom(phantom_id: '')
      expect(result[:success]).to be false
      expect(result[:error]).to be_a(String)
    end

    it 'uses injected engine' do
      eng  = Legion::Extensions::Agentic::Defense::Phantom::Helpers::PhantomEngine.new
      limb = eng.register_removal(capability_name: 'injected-cap')
      result = client.acknowledge_phantom(phantom_id: limb.id, engine: eng)
      expect(result[:acknowledged]).to be true
    end
  end

  describe '#phantom_status' do
    before do
      client.register_removal(capability_name: 'lex-http')
      client.register_removal(capability_name: 'lex-vault')
    end

    it 'returns success: true' do
      expect(client.phantom_status[:success]).to be true
    end

    it 'returns total count' do
      expect(client.phantom_status[:total]).to eq(2)
    end

    it 'returns active count' do
      expect(client.phantom_status[:active]).to be >= 0
    end

    it 'returns by_state breakdown' do
      expect(client.phantom_status[:by_state]).to be_a(Hash)
    end

    it 'returns total_activations' do
      client.process_stimulus(stimulus: 'event', domain: :any)
      expect(client.phantom_status[:total_activations]).to be >= 2
    end

    it 'uses injected engine' do
      eng = Legion::Extensions::Agentic::Defense::Phantom::Helpers::PhantomEngine.new
      eng.register_removal(capability_name: 'cap')
      result = client.phantom_status(engine: eng)
      expect(result[:total]).to eq(1)
    end
  end

  describe '#decay_all' do
    before { client.register_removal(capability_name: 'lex-redis') }

    it 'returns success: true' do
      expect(client.decay_all[:success]).to be true
    end

    it 'returns resolved_this_cycle count' do
      expect(client.decay_all[:resolved_this_cycle]).to be >= 0
    end

    it 'includes total in result' do
      expect(client.decay_all[:total]).to be >= 0
    end

    it 'decays phantom intensity' do
      client.phantom_status[:by_state][:acute]
      client.decay_all
      after_report = client.phantom_status
      expect(after_report[:total]).to be >= 0
    end

    it 'uses injected engine' do
      eng = Legion::Extensions::Agentic::Defense::Phantom::Helpers::PhantomEngine.new
      eng.register_removal(capability_name: 'cap')
      result = client.decay_all(engine: eng)
      expect(result[:success]).to be true
    end
  end
end
