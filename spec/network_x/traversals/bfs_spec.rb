RSpec.describe NetworkX::Graph do
  subject { graph }

  let(:graph) { described_class.new(type: 'undirected') }

  before do
    graph.add_nodes(%w[A B])
    graph.add_edge('A', 'B')
    graph.add_edges([%w[A C], %w[C D]])
    graph.add_node('E')
  end

  context 'when bfs_edges is called' do
    subject { NetworkX.bfs_edges(graph, 'A') }

    it do
      is_expected.to eq([%w[A B], %w[A C], %w[C D]])
    end
  end

  context 'when bfs_successors is called' do
    subject { NetworkX.bfs_successors(graph, 'A') }

    it do
      is_expected.to eq('A' => %w[B C], 'C' => ['D'])
    end
  end

  context 'when bfs_predecessors is called' do
    subject { NetworkX.bfs_predecessors(graph, 'A') }

    it do
      is_expected.to eq('B' => 'A', 'C' => 'A', 'D' => 'C')
    end
  end

  it 'bfs_nodes' do
    tree = NetworkX::Graph.new
    tree.add_nodes('a'..'o')
    tree.add_edges([%w[a b], %w[b c], %w[c h], %w[c i], %w[b d], %w[a e], %w[e f], %w[f j], %w[e g], %w[g k]])

    expect(tree.bfs_nodes('a')).to eq %w[a b e c d f g h i j k]
  end

  it 'test bfs_edge' do
    edges = [[1, 2], [1, 3], [2, 4], [2, 5], [3, 6], [3, 7]]

    g = NetworkX::Graph.new
    g.add_nodes_from(1..7)
    g.add_edges_from(edges)
    expect(g.bfs_edges(1)).to eq(edges)
  end

  it 'test bfs_edge (ABC051 D - Maze Master many paths)' do
    # https://atcoder.jp/contests/abc151/submissions/36396660
    def bfs(sy, sx, graph)
      dist = {}
      dist[[sy, sx]] = 0
      graph.each_bfs_edge([sy, sx]) do |from, to|
        dist[to] = dist[from] + 1
      end
      dist.values.max
    end

    h, w = 12, 12
    grid_graph = NetworkX.grid_2d_graph(h, w)
    ans = 0
    h.times do |y|
      w.times do |x|
        tmp = bfs(y, x, grid_graph)
        ans = tmp if ans < tmp
      end
    end
    expect(ans).to be 22
  end
end
