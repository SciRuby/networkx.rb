RSpec.describe NetworkX::Graph do
  subject { graph }

  let(:graph) { described_class.new(type: 'undirected') }

  before do
    graph.add_nodes(%w[A B])
    graph.add_edge('A', 'B')
    graph.add_edges([%w[A C], %w[B D]])
    graph.add_node('E')
  end

  context 'when dfs_edges is called' do
    subject { NetworkX.dfs_edges(graph, 'A') }

    it do
      is_expected.to eq([%w[A C], %w[A B], %w[B D]])
    end
  end

  context 'when dfs_successors is called' do
    subject { NetworkX.dfs_successors(graph, 'A') }

    it do
      is_expected.to eq('A' => %w[C B], 'B' => ['D'])
    end
  end

  context 'when dfs_predecessors is called' do
    subject { NetworkX.dfs_predecessors(graph, 'A') }

    it do
      is_expected.to eq('B' => 'A', 'C' => 'A', 'D' => 'B')
    end
  end
end
