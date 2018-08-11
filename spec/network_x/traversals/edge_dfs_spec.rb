RSpec.describe NetworkX::DiGraph do
  subject { graph }

  let(:graph) { described_class.new(type: 'directed') }

  before do
    graph.add_nodes(%w[A B])
    graph.add_edge('A', 'B')
    graph.add_edges([%w[B A], %w[B D]])
    graph.add_node('E')
  end

  context 'when dfs_edges is called' do
    subject { NetworkX.edge_dfs(graph, 'A') }

    it do
      is_expected.to eq([%w[A B], %w[B A], %w[B D]])
    end
  end
end
