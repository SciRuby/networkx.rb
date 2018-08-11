RSpec.describe NetworkX::Graph do
  subject { graph }

  let(:graph) { described_class.new(type: 'undirected') }

  before do
    graph.add_nodes(%w[A B])
    graph.add_edge('A', 'B')
    graph.add_edges([%w[A C], %w[C D]])
    graph.add_node('E')
  end

  context 'when astar_path is called' do
    subject { NetworkX.astar_path(graph, 'B', 'D') }

    it do
      is_expected.to eq(%w[D C A B])
    end
  end

  context 'when astar_path_length is called' do
    subject { NetworkX.astar_path_length(graph, 'B', 'D') }

    it do
      is_expected.to eq(3)
    end
  end
end
