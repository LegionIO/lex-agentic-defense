# frozen_string_literal: true

require 'legion/extensions/agentic/defense/phantom/client'

RSpec.describe Legion::Extensions::Agentic::Defense::Phantom::Client do
  subject(:client) { described_class.new }

  it 'includes the CognitivePhantom runner' do
    expect(client).to respond_to(:register_removal)
    expect(client).to respond_to(:process_stimulus)
    expect(client).to respond_to(:acknowledge_phantom)
    expect(client).to respond_to(:phantom_status)
    expect(client).to respond_to(:decay_all)
  end

  it 'can be instantiated with keyword splat' do
    expect { described_class.new(foo: :bar) }.not_to raise_error
  end

  describe 'full lifecycle' do
    it 'registers, triggers, acknowledges, and decays a phantom' do
      reg = client.register_removal(capability_name: 'lex-ssh', capability_domain: :remote)
      expect(reg[:success]).to be true

      stim = client.process_stimulus(stimulus: 'ssh connect attempt', domain: :any)
      expect(stim[:fired_count]).to be >= 1

      ack = client.acknowledge_phantom(phantom_id: reg[:phantom_id])
      expect(ack[:acknowledged]).to be true

      decay = client.decay_all
      expect(decay[:success]).to be true
    end

    it 'tracks multiple phantom removals independently' do
      client.register_removal(capability_name: 'lex-http')
      client.register_removal(capability_name: 'lex-redis')
      client.register_removal(capability_name: 'lex-vault')

      status = client.phantom_status
      expect(status[:total]).to eq(3)
      expect(status[:active]).to eq(3)
    end

    it 'resolves phantom after many acknowledge calls' do
      reg = client.register_removal(capability_name: 'short-lived-cap')
      50.times { client.acknowledge_phantom(phantom_id: reg[:phantom_id]) }
      status = client.phantom_status
      resolved = status[:by_state][:resolved]
      expect(resolved).to be >= 1
    end
  end
end
