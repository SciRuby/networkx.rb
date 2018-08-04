require 'spec_helper'

RSpec.describe NetworkX::Graph do
  subject { graph }

  let(:graph) { described_class.new }

  before do
    graph.add_edge(1, 2)
    graph.add_edge(2, 4)
    graph.add_edge(1, 4)
    graph.add_edge(5, 2)
  end

  context 'when mis is called' do
    subject { NetworkX.maximal_independent_set(graph, [1]) }

    it { is_expected.to eq([1, 5]) }
  end
end
