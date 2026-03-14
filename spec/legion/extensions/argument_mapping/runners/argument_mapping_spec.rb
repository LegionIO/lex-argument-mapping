# frozen_string_literal: true

RSpec.describe Legion::Extensions::ArgumentMapping::Runners::ArgumentMapping do
  let(:client) { Legion::Extensions::ArgumentMapping::Client.new }

  describe '#create_argument' do
    it 'creates an argument and returns success' do
      result = client.create_argument(claim: 'We should reduce emissions')
      expect(result[:success]).to be true
      expect(result[:argument][:claim]).to eq('We should reduce emissions')
    end

    it 'accepts a warrant' do
      result = client.create_argument(claim: 'Test', warrant: 'Evidence shows it')
      expect(result[:argument][:warrant]).to eq('Evidence shows it')
    end

    it 'accepts a qualifier' do
      result = client.create_argument(claim: 'Test', qualifier: :certainly)
      expect(result[:argument][:qualifier]).to eq(:certainly)
    end
  end

  describe '#add_argument_ground' do
    let(:argument_id) { client.create_argument(claim: 'Test claim')[:argument][:id] }

    it 'adds a ground successfully' do
      result = client.add_argument_ground(argument_id: argument_id, ground: 'Strong evidence')
      expect(result[:success]).to be true
      expect(result[:argument][:grounds]).to include('Strong evidence')
    end

    it 'returns failure for unknown id' do
      result = client.add_argument_ground(argument_id: 'bad', ground: 'Evidence')
      expect(result[:success]).to be false
    end
  end

  describe '#add_argument_backing' do
    let(:argument_id) { client.create_argument(claim: 'Test claim')[:argument][:id] }

    it 'adds backing successfully' do
      result = client.add_argument_backing(argument_id: argument_id, backing: 'Academic study')
      expect(result[:success]).to be true
      expect(result[:argument][:backing]).to include('Academic study')
    end

    it 'returns failure for unknown id' do
      result = client.add_argument_backing(argument_id: 'bad', backing: 'Source')
      expect(result[:success]).to be false
    end
  end

  describe '#add_argument_rebuttal' do
    let(:argument_id) { client.create_argument(claim: 'Test claim')[:argument][:id] }

    it 'adds a rebuttal successfully' do
      result = client.add_argument_rebuttal(argument_id: argument_id, content: 'Counter', impact: 0.7)
      expect(result[:success]).to be true
      expect(result[:argument][:rebuttals].first[:impact]).to eq(0.7)
    end

    it 'returns failure for unknown id' do
      result = client.add_argument_rebuttal(argument_id: 'bad', content: 'Counter')
      expect(result[:success]).to be false
    end
  end

  describe '#assess_argument_strength' do
    let(:argument_id) do
      id = client.create_argument(claim: 'Test', warrant: 'Because')[:argument][:id]
      3.times { |i| client.add_argument_ground(argument_id: id, ground: "G#{i}") }
      id
    end

    it 'returns a strength assessment' do
      result = client.assess_argument_strength(argument_id: argument_id)
      expect(result[:success]).to be true
      expect(result[:strength]).to be_a(Float)
      expect(result[:strength_label]).to be_a(Symbol)
    end

    it 'includes sound and rebutted flags' do
      result = client.assess_argument_strength(argument_id: argument_id)
      expect(result).to include(:sound, :rebutted)
    end

    it 'returns failure for unknown id' do
      result = client.assess_argument_strength(argument_id: 'nope')
      expect(result[:success]).to be false
    end
  end

  describe '#sound_arguments_report' do
    it 'returns success with count and arguments list' do
      result = client.sound_arguments_report
      expect(result[:success]).to be true
      expect(result[:count]).to be_a(Integer)
      expect(result[:arguments]).to be_an(Array)
    end

    it 'includes sound arguments after creation' do
      id = client.create_argument(claim: 'Sound arg', warrant: 'Valid reason')[:argument][:id]
      3.times { |i| client.add_argument_ground(argument_id: id, ground: "G#{i}") }
      2.times { |i| client.add_argument_backing(argument_id: id, backing: "B#{i}") }

      result = client.sound_arguments_report
      expect(result[:count]).to be >= 1
    end
  end

  describe '#rebutted_arguments_report' do
    it 'returns success with count and arguments list' do
      result = client.rebutted_arguments_report
      expect(result[:success]).to be true
      expect(result[:count]).to be_a(Integer)
      expect(result[:arguments]).to be_an(Array)
    end

    it 'includes rebutted arguments after rebuttal added' do
      id = client.create_argument(claim: 'Rebutted arg')[:argument][:id]
      client.add_argument_rebuttal(argument_id: id, content: 'Devastating counter', impact: 0.9)

      result = client.rebutted_arguments_report
      expect(result[:count]).to be >= 1
    end
  end

  describe '#strongest_arguments_report' do
    before do
      2.times do |i|
        id = client.create_argument(claim: "Claim #{i}", warrant: "Warrant #{i}")[:argument][:id]
        i.times { |j| client.add_argument_ground(argument_id: id, ground: "G#{j}") }
      end
    end

    it 'returns success with ordered arguments' do
      result = client.strongest_arguments_report(limit: 2)
      expect(result[:success]).to be true
      expect(result[:arguments]).to be_an(Array)
    end

    it 'respects the limit' do
      result = client.strongest_arguments_report(limit: 1)
      expect(result[:count]).to be <= 1
    end
  end

  describe '#update_argument_mapping' do
    it 'runs decay and returns success' do
      client.create_argument(claim: 'Test')
      result = client.update_argument_mapping
      expect(result[:success]).to be true
      expect(result[:arguments_processed]).to be_a(Integer)
    end
  end

  describe '#argument_mapping_stats' do
    it 'returns success with counts' do
      result = client.argument_mapping_stats
      expect(result[:success]).to be true
      expect(result).to include(:total_arguments, :sound_arguments, :rebutted_arguments)
    end

    it 'reflects created arguments' do
      client.create_argument(claim: 'Stat test')
      result = client.argument_mapping_stats
      expect(result[:total_arguments]).to be >= 1
    end
  end
end
