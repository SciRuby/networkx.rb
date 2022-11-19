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

  it 'multigraph' do
    graph = NetworkX::MultiDiGraph.new
    graph.add_edge(:A, :B)
    graph.add_edges([%i[B A], %i[B D]])

    expect(NetworkX.edge_dfs(graph, :A)).to eq([[:A, :B, 0], [:B, :A, 0], [:B, :D, 0]])
  end

  it 'edges_dfes to digraph with option' do
    graph = NetworkX::DiGraph.new
    graph.add_edge(:A, :B)
    graph.add_edges([%i[B C], %i[C D]])

    expect(NetworkX.edge_dfs(graph, :A, :reverse)).to eq([])
    expect(NetworkX.edge_dfs(graph, :D, :ignore)).to eq([%i[D C], %i[C B], %i[B A]])
    expect(NetworkX.edge_dfs(graph, :D, :reverse)).to eq([%i[D C], %i[C B], %i[B A]])
  end

  it 'test bfs_edge (ABC051 D - Maze Master sample_01)' do
    # # https://atcoder.jp/contests/abc151/submissions/36398103
    g = NetworkX::Graph.new
    g.add_nodes_from(0...2)
    g.add_edge(0, 1)
    expect(g.bfs_edges(0)).to eq([[0, 1]])
    expect(g.bfs_edges(1)).to eq([[1, 0]])
  end

  it 'test dfs_edges' do
    edges = [[1, 2], [1, 3], [2, 4], [2, 5], [3, 6], [3, 7]]
    dfs_edges = [[1, 2], [2, 4], [2, 5], [1, 3], [3, 6], [3, 7]]

    g = NetworkX::Graph.new
    g.add_nodes_from(1..7)
    g.add_edges_from(edges)
    expect(g.dfs_edges(1)).to eq(dfs_edges)
  end

  it 'tes dfs_edges for object other than integert' do
    tree = NetworkX::Graph.new
    tree.add_nodes('a'..'o')
    tree.add_edges([%w[a b], %w[b c], %w[c h], %w[c i], %w[b d], %w[a e], %w[e f], %w[f j], %w[e g], %w[g k]])

    expect(tree.dfs_edges('a')).to eq [%w[a b], %w[b c], %w[c h], %w[c i], %w[b d], %w[a e],
                                       %w[e f], %w[f j], %w[e g], %w[g k]]
  end

  it 'test dfs_edges to line graph (ABC133 E sample1)' do
    n, _k = 4, 3
    edges = [[1, 2], [2, 3], [3, 4]]

    g = NetworkX::Graph.new
    g.add_nodes_from(1..n)
    g.add_edges_from(edges)
    expect(g.dfs_edges(1)).to eq([[1, 2], [2, 3], [3, 4]])
  end

  it 'test dfs_edges to line graph (ABC133 E sample2)' do
    n, _k = 5, 4
    edges = [[1, 2], [1, 3], [1, 4], [4, 5]]

    g = NetworkX::Graph.new
    g.add_nodes_from(1..n)
    g.add_edges_from(edges)
    expect(g.dfs_edges(1)).to eq([[1, 2], [1, 3], [1, 4], [4, 5]])
  end
end
