# frozen_string_literal: true

RSpec.describe Legion::Extensions::ArgumentMapping::Client do
  let(:client) { described_class.new }

  it 'responds to all runner methods' do
    expect(client).to respond_to(:create_argument)
    expect(client).to respond_to(:add_argument_ground)
    expect(client).to respond_to(:add_argument_backing)
    expect(client).to respond_to(:add_argument_rebuttal)
    expect(client).to respond_to(:assess_argument_strength)
    expect(client).to respond_to(:sound_arguments_report)
    expect(client).to respond_to(:rebutted_arguments_report)
    expect(client).to respond_to(:strongest_arguments_report)
    expect(client).to respond_to(:update_argument_mapping)
    expect(client).to respond_to(:argument_mapping_stats)
  end
end
