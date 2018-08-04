require 'spec_helper'

RSpec.describe NetworkX::DiGraph do
  subject { graph }

  let(:graph) { described_class.new }

  before do
    graph.add_edge(1, 2)
    graph.add_edge(2, 4)
    graph.add_edge(1, 4)
    graph.add_edge(5, 6)
    graph.add_edge(7, 6)
    graph.add_edge(5, 7)
  end

  context 'when ancestors is called' do
    subject { NetworkX.ancestors(graph, 4) }

    it { is_expected.to eq([1, 2]) }
  end

  context 'when descendants is called' do
    subject { NetworkX.descendants(graph, 1) }

    it { is_expected.to eq([2, 4]) }
  end

  context 'when topological_sort is called' do
    subject { NetworkX.topological_sort(graph) }

    it { is_expected.to eq([1, 5, 2, 7, 4, 6]) }
  end
end
