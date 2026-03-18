# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Defense::Phantom::Helpers::PhantomSignal do
  let(:phantom_id) { SecureRandom.uuid }

  subject(:signal) do
    described_class.new(
      phantom_limb_id:      phantom_id,
      stimulus:             'http.get request',
      trigger_type:         :stimulus_match,
      intensity_at_trigger: 0.75
    )
  end

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(signal.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores phantom_limb_id' do
      expect(signal.phantom_limb_id).to eq(phantom_id)
    end

    it 'stores stimulus' do
      expect(signal.stimulus).to eq('http.get request')
    end

    it 'stores trigger_type' do
      expect(signal.trigger_type).to eq(:stimulus_match)
    end

    it 'stores intensity_at_trigger' do
      expect(signal.intensity_at_trigger).to be_within(0.001).of(0.75)
    end

    it 'clamps intensity_at_trigger to [0, 1]' do
      over = described_class.new(phantom_limb_id: phantom_id, stimulus: 's', trigger_type: :habitual, intensity_at_trigger: 2.0)
      under = described_class.new(phantom_limb_id: phantom_id, stimulus: 's', trigger_type: :habitual, intensity_at_trigger: -0.5)
      expect(over.intensity_at_trigger).to eq(1.0)
      expect(under.intensity_at_trigger).to eq(0.0)
    end

    it 'sets timestamp to current utc time' do
      expect(signal.timestamp).to be_a(Time)
    end
  end

  describe '#to_h' do
    it 'returns a hash with expected keys' do
      h = signal.to_h
      expect(h).to include(:id, :phantom_limb_id, :stimulus, :trigger_type, :intensity_at_trigger, :timestamp)
    end

    it 'intensity_at_trigger is rounded to 10 decimal places' do
      h = signal.to_h
      expect(h[:intensity_at_trigger]).to eq(signal.intensity_at_trigger.round(10))
    end
  end
end
