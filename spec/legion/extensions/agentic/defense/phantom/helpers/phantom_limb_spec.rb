# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Defense::Phantom::Helpers::PhantomLimb do
  subject(:limb) do
    described_class.new(capability_name: 'lex-http', capability_domain: :network)
  end

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(limb.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores capability_name' do
      expect(limb.capability_name).to eq('lex-http')
    end

    it 'stores capability_domain' do
      expect(limb.capability_domain).to eq(:network)
    end

    it 'sets removed_at to now' do
      expect(limb.removed_at).to be_a(Time)
    end

    it 'starts at INITIAL_INTENSITY' do
      expect(limb.intensity).to be_within(0.001).of(Legion::Extensions::Agentic::Defense::Phantom::Helpers::Constants::INITIAL_INTENSITY)
    end

    it 'starts with zero activation_count' do
      expect(limb.activation_count).to eq(0)
    end

    it 'has nil last_triggered initially' do
      expect(limb.last_triggered).to be_nil
    end

    it 'has empty trigger_history' do
      expect(limb.trigger_history).to be_empty
    end
  end

  describe '#state' do
    it 'returns :acute at initial intensity' do
      expect(limb.state).to eq(:acute)
    end

    it 'transitions to :adapting as intensity drops' do
      7.times { limb.decay! }
      expect(%i[adapting acute residual]).to include(limb.state)
    end
  end

  describe '#resolved?' do
    it 'returns false at initial intensity' do
      expect(limb.resolved?).to be false
    end

    it 'returns true when intensity is at MIN_INTENSITY' do
      160.times { limb.decay! }
      expect(limb.resolved?).to be true
    end
  end

  describe '#trigger!' do
    it 'returns a PhantomSignal' do
      result = limb.trigger!('http.get request')
      expect(result).to be_a(Legion::Extensions::Agentic::Defense::Phantom::Helpers::PhantomSignal)
    end

    it 'increments activation_count' do
      limb.trigger!('test')
      expect(limb.activation_count).to eq(1)
    end

    it 'sets last_triggered' do
      limb.trigger!('test')
      expect(limb.last_triggered).to be_a(Time)
    end

    it 'adds signal to trigger_history' do
      limb.trigger!('test')
      expect(limb.trigger_history.size).to eq(1)
    end

    it 'caps trigger_history at 50 entries' do
      55.times { |i| limb.trigger!("stimulus_#{i}") }
      expect(limb.trigger_history.size).to eq(50)
    end

    it 'returns false when resolved' do
      160.times { limb.decay! }
      expect(limb.trigger!('test')).to be false
    end

    it 'classifies trigger as :stimulus_match when stimulus contains capability name' do
      signal = limb.trigger!('lex-http request fired')
      expect(signal.trigger_type).to eq(:stimulus_match)
    end

    it 'classifies as :contextual_association for a fresh limb with generic stimulus' do
      fresh = described_class.new(capability_name: 'lex-redis', capability_domain: :cache)
      signal = fresh.trigger!('some unrelated event')
      expect(signal.trigger_type).to eq(:contextual_association)
    end

    it 'classifies repeated rapid activations as :temporal_pattern' do
      2.times { limb.trigger!('something') }
      signal = limb.trigger!('something')
      expect(signal.trigger_type).to eq(:temporal_pattern)
    end

    it 'classifies as :habitual when activation_count > 10 and last trigger was long ago' do
      fresh = described_class.new(capability_name: 'lex-vault', capability_domain: :secrets)
      11.times { fresh.trigger!('some event') }
      fresh.instance_variable_set(:@last_triggered, Time.now.utc - 120)
      signal = fresh.trigger!('some event')
      expect(signal.trigger_type).to eq(:habitual)
    end

    it 'classifies signal with a valid trigger type' do
      fresh = described_class.new(capability_name: 'lex-vault', capability_domain: :secrets)
      15.times { fresh.trigger!('some event') }
      signal = fresh.trigger!('some event')
      expect(Legion::Extensions::Agentic::Defense::Phantom::Helpers::Constants::TRIGGER_TYPES).to include(signal.trigger_type)
    end
  end

  describe '#decay!' do
    it 'reduces intensity by INTENSITY_DECAY' do
      before = limb.intensity
      limb.decay!
      expect(limb.intensity).to be_within(0.001).of(before - Legion::Extensions::Agentic::Defense::Phantom::Helpers::Constants::INTENSITY_DECAY)
    end

    it 'does not drop below MIN_INTENSITY' do
      200.times { limb.decay! }
      expect(limb.intensity).to eq(Legion::Extensions::Agentic::Defense::Phantom::Helpers::Constants::MIN_INTENSITY)
    end

    it 'does nothing when already resolved' do
      160.times { limb.decay! }
      resolved_intensity = limb.intensity
      limb.decay!
      expect(limb.intensity).to eq(resolved_intensity)
    end
  end

  describe '#adapt!' do
    it 'reduces intensity faster than decay!' do
      limb2 = described_class.new(capability_name: 'lex-http', capability_domain: :network)
      limb.adapt!
      limb2.decay!
      expect(limb.intensity).to be < limb2.intensity
    end

    it 'does not drop below MIN_INTENSITY' do
      100.times { limb.adapt! }
      expect(limb.intensity).to eq(Legion::Extensions::Agentic::Defense::Phantom::Helpers::Constants::MIN_INTENSITY)
    end

    it 'does nothing when already resolved' do
      100.times { limb.adapt! }
      resolved_intensity = limb.intensity
      limb.adapt!
      expect(limb.intensity).to eq(resolved_intensity)
    end
  end

  describe '#to_h' do
    it 'returns a hash with expected keys' do
      h = limb.to_h
      expect(h).to include(:id, :capability_name, :capability_domain, :removed_at, :intensity, :activation_count, :state, :resolved)
    end

    it 'reflects resolved status' do
      160.times { limb.decay! }
      expect(limb.to_h[:resolved]).to be true
    end
  end
end
