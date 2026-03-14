# frozen_string_literal: true

RSpec.describe Legion::Extensions::ArgumentMapping::Helpers::ArgumentEngine do
  subject(:engine) { described_class.new }

  describe '#initialize' do
    it 'starts with empty arguments' do
      expect(engine.arguments).to be_empty
    end

    it 'starts with empty history' do
      expect(engine.history).to be_empty
    end
  end

  describe '#create_argument' do
    it 'creates an argument and returns success' do
      result = engine.create_argument(claim: 'The sky is blue')
      expect(result[:success]).to be true
      expect(result[:argument][:claim]).to eq('The sky is blue')
    end

    it 'assigns a unique id' do
      r1 = engine.create_argument(claim: 'Claim A')
      r2 = engine.create_argument(claim: 'Claim B')
      expect(r1[:argument][:id]).not_to eq(r2[:argument][:id])
    end

    it 'stores argument in @arguments' do
      engine.create_argument(claim: 'Test claim')
      expect(engine.arguments).not_to be_empty
    end

    it 'accepts warrant and qualifier' do
      result = engine.create_argument(
        claim:     'AI should be regulated',
        warrant:   'Unregulated AI poses risks',
        qualifier: :certainly
      )
      expect(result[:argument][:warrant]).to eq('Unregulated AI poses risks')
      expect(result[:argument][:qualifier]).to eq(:certainly)
    end

    it 'returns failure when max arguments reached' do
      Legion::Extensions::ArgumentMapping::Helpers::Constants::MAX_ARGUMENTS.times do |i|
        engine.create_argument(claim: "Claim #{i}")
      end
      result = engine.create_argument(claim: 'One more')
      expect(result[:success]).to be false
      expect(result[:reason]).to eq(:max_arguments_reached)
    end

    it 'adds an entry to history' do
      engine.create_argument(claim: 'Some claim')
      expect(engine.history).not_to be_empty
    end
  end

  describe '#add_ground' do
    let(:argument_id) { engine.create_argument(claim: 'Test')[:argument][:id] }

    it 'adds a ground to the argument' do
      result = engine.add_ground(argument_id: argument_id, ground: 'Evidence A')
      expect(result[:success]).to be true
      expect(result[:argument][:grounds]).to include('Evidence A')
    end

    it 'returns failure for unknown argument_id' do
      result = engine.add_ground(argument_id: 'bad_id', ground: 'Evidence')
      expect(result[:success]).to be false
      expect(result[:reason]).to eq(:not_found)
    end
  end

  describe '#add_backing' do
    let(:argument_id) { engine.create_argument(claim: 'Test')[:argument][:id] }

    it 'adds backing to the argument' do
      result = engine.add_backing(argument_id: argument_id, backing: 'Source A')
      expect(result[:success]).to be true
      expect(result[:argument][:backing]).to include('Source A')
    end

    it 'returns failure for unknown argument_id' do
      result = engine.add_backing(argument_id: 'bad_id', backing: 'Source')
      expect(result[:success]).to be false
      expect(result[:reason]).to eq(:not_found)
    end
  end

  describe '#add_rebuttal' do
    let(:argument_id) { engine.create_argument(claim: 'Test')[:argument][:id] }

    it 'adds a rebuttal to the argument' do
      result = engine.add_rebuttal(argument_id: argument_id, content: 'Counter-point', impact: 0.7)
      expect(result[:success]).to be true
      expect(result[:argument][:rebuttals].first[:content]).to eq('Counter-point')
    end

    it 'returns failure for unknown argument_id' do
      result = engine.add_rebuttal(argument_id: 'bad_id', content: 'Counter')
      expect(result[:success]).to be false
      expect(result[:reason]).to eq(:not_found)
    end
  end

  describe '#assess_argument' do
    let(:argument_id) do
      id = engine.create_argument(claim: 'Test', warrant: 'Because')[:argument][:id]
      3.times { |i| engine.add_ground(argument_id: id, ground: "G#{i}") }
      id
    end

    it 'returns a full assessment for a known argument' do
      result = engine.assess_argument(argument_id: argument_id)
      expect(result[:success]).to be true
      expect(result).to include(:strength, :strength_label, :sound, :rebutted)
      expect(result[:ground_count]).to eq(3)
    end

    it 'returns failure for unknown argument' do
      result = engine.assess_argument(argument_id: 'nope')
      expect(result[:success]).to be false
      expect(result[:reason]).to eq(:not_found)
    end
  end

  describe '#sound_arguments' do
    it 'returns only sound arguments' do
      id = engine.create_argument(claim: 'Sound claim', warrant: 'Solid warrant')[:argument][:id]
      3.times { |i| engine.add_ground(argument_id: id, ground: "G#{i}") }
      2.times { |i| engine.add_backing(argument_id: id, backing: "B#{i}") }

      engine.create_argument(claim: 'Weak claim')

      expect(engine.sound_arguments.size).to eq(1)
      expect(engine.sound_arguments.first.claim).to eq('Sound claim')
    end
  end

  describe '#rebutted_arguments' do
    it 'returns only rebutted arguments' do
      id = engine.create_argument(claim: 'Test claim')[:argument][:id]
      engine.add_rebuttal(argument_id: id, content: 'Major objection', impact: 0.9)

      engine.create_argument(claim: 'Unrebutted claim')

      expect(engine.rebutted_arguments.size).to eq(1)
    end
  end

  describe '#arguments_by_domain' do
    it 'returns arguments matching the given domain' do
      engine.create_argument(claim: 'Policy claim', domain: :policy)
      engine.create_argument(claim: 'Science claim', domain: :science)
      engine.create_argument(claim: 'Another policy', domain: :policy)

      results = engine.arguments_by_domain(domain: :policy)
      expect(results.size).to eq(2)
      results.each { |a| expect(a.domain).to eq(:policy) }
    end
  end

  describe '#strongest_arguments' do
    before do
      3.times do |i|
        id = engine.create_argument(claim: "Claim #{i}", warrant: "Warrant #{i}")[:argument][:id]
        i.times { |j| engine.add_ground(argument_id: id, ground: "G#{j}") }
      end
    end

    it 'returns arguments sorted by descending strength' do
      results = engine.strongest_arguments(limit: 3)
      strengths = results.map(&:strength)
      expect(strengths).to eq(strengths.sort.reverse)
    end

    it 'respects the limit parameter' do
      results = engine.strongest_arguments(limit: 2)
      expect(results.size).to be <= 2
    end
  end

  describe '#weakest_arguments' do
    before do
      3.times do |i|
        id = engine.create_argument(claim: "Claim #{i}", warrant: "Warrant #{i}")[:argument][:id]
        i.times { |j| engine.add_ground(argument_id: id, ground: "G#{j}") }
      end
    end

    it 'returns arguments sorted by ascending strength' do
      results = engine.weakest_arguments(limit: 3)
      strengths = results.map(&:strength)
      expect(strengths).to eq(strengths.sort)
    end
  end

  describe '#decay_all' do
    it 'returns the argument count' do
      engine.create_argument(claim: 'A')
      engine.create_argument(claim: 'B')
      expect(engine.decay_all).to eq(2)
    end
  end

  describe '#to_h' do
    it 'returns stats summary' do
      h = engine.to_h
      expect(h).to include(:total_arguments, :sound_arguments, :rebutted_arguments, :history_entries)
    end

    it 'reflects current counts' do
      engine.create_argument(claim: 'Test')
      expect(engine.to_h[:total_arguments]).to eq(1)
    end
  end
end
