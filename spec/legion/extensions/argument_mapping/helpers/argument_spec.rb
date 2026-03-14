# frozen_string_literal: true

RSpec.describe Legion::Extensions::ArgumentMapping::Helpers::Argument do
  subject(:argument) do
    described_class.new(
      id:        'arg_1',
      claim:     'We should invest in renewable energy',
      domain:    :policy,
      warrant:   'Renewable energy reduces carbon emissions',
      qualifier: :probably
    )
  end

  describe '#initialize' do
    it 'sets id, claim, domain, warrant, qualifier' do
      expect(argument.id).to eq('arg_1')
      expect(argument.claim).to eq('We should invest in renewable energy')
      expect(argument.domain).to eq(:policy)
      expect(argument.warrant).to eq('Renewable energy reduces carbon emissions')
      expect(argument.qualifier).to eq(:probably)
    end

    it 'starts with empty grounds, backing, and rebuttals' do
      expect(argument.grounds).to be_empty
      expect(argument.backing).to be_empty
      expect(argument.rebuttals).to be_empty
    end

    it 'defaults qualifier to :presumably when not specified' do
      a = described_class.new(id: 'x', claim: 'Some claim', domain: :general)
      expect(a.qualifier).to eq(:presumably)
    end

    it 'defaults warrant to nil' do
      a = described_class.new(id: 'x', claim: 'Some claim', domain: :general)
      expect(a.warrant).to be_nil
    end

    it 'sets created_at' do
      expect(argument.created_at).not_to be_nil
    end
  end

  describe '#add_ground' do
    it 'appends a ground to the grounds array' do
      argument.add_ground(ground: 'Solar prices fell 90% in a decade')
      expect(argument.grounds).to include('Solar prices fell 90% in a decade')
    end

    it 'accumulates multiple grounds' do
      argument.add_ground(ground: 'Ground one')
      argument.add_ground(ground: 'Ground two')
      expect(argument.grounds.size).to eq(2)
    end
  end

  describe '#add_backing' do
    it 'appends backing to the backing array' do
      argument.add_backing(backing: 'IPCC report 2023')
      expect(argument.backing).to include('IPCC report 2023')
    end

    it 'accumulates multiple backing entries' do
      argument.add_backing(backing: 'Study A')
      argument.add_backing(backing: 'Study B')
      expect(argument.backing.size).to eq(2)
    end
  end

  describe '#add_rebuttal' do
    it 'appends a rebuttal with content and impact' do
      argument.add_rebuttal(content: 'High upfront costs', impact: 0.6)
      expect(argument.rebuttals.size).to eq(1)
      expect(argument.rebuttals.first[:content]).to eq('High upfront costs')
      expect(argument.rebuttals.first[:impact]).to eq(0.6)
    end

    it 'defaults impact to 0.5' do
      argument.add_rebuttal(content: 'Some objection')
      expect(argument.rebuttals.first[:impact]).to eq(0.5)
    end

    it 'clamps impact above 1.0' do
      argument.add_rebuttal(content: 'Too strong', impact: 1.5)
      expect(argument.rebuttals.first[:impact]).to eq(1.0)
    end

    it 'clamps impact below 0.0' do
      argument.add_rebuttal(content: 'Too weak', impact: -0.5)
      expect(argument.rebuttals.first[:impact]).to eq(0.0)
    end
  end

  describe '#strength' do
    context 'with no grounds, no warrant, no backing' do
      it 'returns 0.0 for bare argument' do
        a = described_class.new(id: 'x', claim: 'Claim', domain: :general)
        expect(a.strength).to eq(0.0)
      end
    end

    context 'with warrant only' do
      it 'contributes warrant_score * WARRANT_WEIGHT' do
        a = described_class.new(id: 'x', claim: 'Claim', domain: :general, warrant: 'Because')
        expected = 0.8 * Legion::Extensions::ArgumentMapping::Helpers::Constants::WARRANT_WEIGHT
        expect(a.strength).to be_within(0.001).of(expected)
      end
    end

    context 'with full grounds (3+), warrant, full backing (2+)' do
      before do
        3.times { |i| argument.add_ground(ground: "Ground #{i}") }
        2.times { |i| argument.add_backing(backing: "Backing #{i}") }
      end

      it 'reaches maximum non-rebutted score' do
        consts = Legion::Extensions::ArgumentMapping::Helpers::Constants
        expected = (1.0 * consts::GROUND_WEIGHT) +
                   (0.8 * consts::WARRANT_WEIGHT) +
                   (1.0 * consts::BACKING_WEIGHT)
        expect(argument.strength).to be_within(0.001).of(expected)
      end
    end

    context 'with a devastating rebuttal' do
      before do
        3.times { |i| argument.add_ground(ground: "Ground #{i}") }
        argument.add_rebuttal(content: 'Fatal objection', impact: 1.0)
      end

      it 'reduces strength due to rebuttal penalty' do
        a_no_rebuttal = described_class.new(
          id: 'y', claim: 'Claim', domain: :general, warrant: 'Because'
        )
        3.times { |i| a_no_rebuttal.add_ground(ground: "G#{i}") }
        expect(argument.strength).to be < a_no_rebuttal.strength
      end
    end

    it 'is clamped to 0..1' do
      3.times { |i| argument.add_ground(ground: "G#{i}") }
      2.times { |i| argument.add_backing(backing: "B#{i}") }
      expect(argument.strength).to be >= 0.0
      expect(argument.strength).to be <= 1.0
    end
  end

  describe '#strength_label' do
    it 'returns :compelling for strength >= 0.8' do
      3.times { |i| argument.add_ground(ground: "G#{i}") }
      2.times { |i| argument.add_backing(backing: "B#{i}") }
      label = argument.strength_label
      expect(%i[compelling strong]).to include(label)
    end

    it 'returns :fallacious for zero-strength argument' do
      a = described_class.new(id: 'x', claim: 'Empty', domain: :general)
      expect(a.strength_label).to eq(:fallacious)
    end
  end

  describe '#sound?' do
    context 'when strength >= 0.6, warrant present, grounds non-empty' do
      before do
        3.times { |i| argument.add_ground(ground: "Ground #{i}") }
        2.times { |i| argument.add_backing(backing: "Backing #{i}") }
      end

      it 'returns true' do
        expect(argument.sound?).to be true
      end
    end

    context 'when warrant is nil' do
      it 'returns false' do
        a = described_class.new(id: 'x', claim: 'Claim', domain: :general)
        3.times { |i| a.add_ground(ground: "G#{i}") }
        expect(a.sound?).to be false
      end
    end

    context 'when grounds is empty' do
      it 'returns false' do
        a = described_class.new(id: 'x', claim: 'Claim', domain: :general, warrant: 'Because')
        expect(a.sound?).to be false
      end
    end

    context 'when strength is below 0.6' do
      it 'returns false' do
        a = described_class.new(id: 'x', claim: 'Claim', domain: :general, warrant: 'Because')
        a.add_ground(ground: 'One ground')
        a.add_rebuttal(content: 'Strong objection', impact: 0.9)
        expect(a.sound?).to be false
      end
    end
  end

  describe '#rebutted?' do
    it 'returns false when there are no rebuttals' do
      expect(argument.rebutted?).to be false
    end

    it 'returns false when all rebuttals have impact <= 0.5' do
      argument.add_rebuttal(content: 'Minor point', impact: 0.4)
      expect(argument.rebutted?).to be false
    end

    it 'returns true when any rebuttal has impact > 0.5' do
      argument.add_rebuttal(content: 'Major objection', impact: 0.8)
      expect(argument.rebutted?).to be true
    end
  end

  describe '#to_h' do
    it 'returns a hash with all expected keys' do
      h = argument.to_h
      expect(h).to include(
        :id, :claim, :domain, :grounds, :warrant, :backing,
        :qualifier, :rebuttals, :strength, :strength_label,
        :sound, :rebutted, :created_at
      )
    end

    it 'reflects current state' do
      argument.add_ground(ground: 'Evidence A')
      h = argument.to_h
      expect(h[:grounds]).to include('Evidence A')
    end
  end
end
