require 'spec_helper'

RSpec.describe NetworkX::DiGraph do
  subject { graph }

  let(:graph) { described_class.new }

  before do
    graph.add_edge(1, 2)
    graph.add_edge(2, 4)
  end

  context 'when capacity_scaling is called' do
    subject { NetworkX.capacity_scaling(graph) }

    it { is_expected.to eq([0, {1=>{2=>0}, 2=>{4=>0}, 4=>{}}]) }
  end
end
