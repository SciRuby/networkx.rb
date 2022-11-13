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

  it 'dfs_edges with limit' do
    graph = NetworkX::Graph.new
    graph.add_edges([[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [4, 5]])
    edges = NetworkX.dfs_edges(graph, 0, 2)
    expect(edges).to eq([[0, 1], [1, 2]])
  end

  it 'dfs_tree' do
    graph = NetworkX::Graph.new
    graph.add_edges([[0, 1], [1, 2], [1, 3], [2, 3], [1, 4], [4, 5], [5, 2], [5, 3], [4, 2]])
    tree = NetworkX.dfs_tree(graph, 0)
    expect(tree.edges.sort).to eq([[0, 1], [1, 2], [1, 3], [1, 4], [4, 5]])
  end

  it 'dfs_tree with limit' do
    graph = NetworkX::Graph.new
    graph.add_edges([[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [4, 5]])
    tree = NetworkX.dfs_tree(graph, 0, 2)
    expect(tree.edges.sort).to eq([[0, 1], [1, 2]])
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
