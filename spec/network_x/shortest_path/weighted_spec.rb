RSpec.describe NetworkX::Graph do
  subject { graph }

  let(:graph) { described_class.new(type: 'undirected') }

  before do
    graph.add_nodes(%w[A B])
    graph.add_edge('A', 'B', weight: 5)
    graph.add_weighted_edges([%w[A C], %w[C D]], [2, 3])
    graph.add_node('E')
  end

  it 'simple single source dijkstra' do
    n, _m = 2, 2
    weighted_edges = [[1, 2, 2], [2, 1, 1]]

    g = NetworkX::DiGraph.new
    g.add_nodes_from(1..n)
    g.add_weighted_edges_from(weighted_edges)

    expect(NetworkX.singlesource_dijkstra_path_length(g, 1)).to eq({1 => 0, 2 => 2})
    expect(NetworkX.dijkstra_path(g, 1, 2)).to eq([1, 2])
    expect(NetworkX.singlesource_dijkstra_path(g, 1)).to eq({1 => [1], 2 => [1, 2]})
  end

  it 'single source dijkstra' do
    # https://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=GRL_1_A&lang=ja
    n, _m, r = 4, 5, 0
    weighted_edges = [[0, 1, 1], [0, 2, 4], [1, 2, 2], [2, 3, 1], [1, 3, 5]]

    g = NetworkX::DiGraph.new
    g.add_nodes_from(0...n)
    g.add_weighted_edges_from(weighted_edges)

    expect(NetworkX.dijkstra_path_length(g, r, 3)).to be 4
    expect(NetworkX.singlesource_dijkstra_path(g, r)).to eq({0 => [0], 1 => [0, 1], 2 => [0, 1, 2], 3 => [0, 1, 2, 3]})
  end

  it 'all pair dijkstra' do
    n, _m = 4, 5
    weighted_edges = [[0, 1, 5], [0, 2, -1], [1, 3, 3], [2, 3, 1], [3, 2, 4]]

    g = NetworkX::DiGraph.new
    g.add_nodes_from(0...n)
    g.add_weighted_edges_from(weighted_edges)

    expect(NetworkX.all_pairs_dijkstra_path_length(g)).to eq [[0, {0 => 0, 1 => 5, 2 => -1, 3 => 0}],
                                                              [1, {1 => 0, 2 => 7, 3 => 3}],
                                                              [2, {2 => 0, 3 => 1}],
                                                              [3, {2 => 4, 3 => 0}]]
    expect(NetworkX.all_pairs_dijkstra_path(g)).to eq [
      {0 => [0], 1 => [0, 1], 2 => [0, 2], 3 => [0, 2, 3]},
      {1 => [1], 3 => [1, 3], 2 => [1, 3, 2]},
      {2 => [2], 3 => [2, 3]},
      {3 => [3], 2 => [3, 2]}
    ]
  end

  context 'when multisource_dijkstra is called' do
    subject { NetworkX.multisource_dijkstra(graph, %w[B A], 'D') }

    it do
      is_expected.to eq([5, %w[A C D]])
    end
  end

  context 'when multisource_dijkstra_path_length is called' do
    subject { NetworkX.multisource_dijkstra_path_length(graph, %w[B A]) }

    it do
      is_expected.to eq('B' => 0, 'A' => 0, 'C' => 2, 'D' => 5)
    end
  end

  context 'when multisource_dijkstra_path is called' do
    subject { NetworkX.multisource_dijkstra_path(graph, %w[B A]) }

    it do
      is_expected.to eq('B' => ['B'], 'A' => ['A'], 'C' => %w[A C], 'D' => %w[A C D])
    end
  end

  context 'when multisource_dijkstra_path is called' do
    subject { NetworkX.multisource_dijkstra_path(graph, %w[B A]) }

    it do
      is_expected.to eq('B' => ['B'], 'A' => ['A'], 'C' => %w[A C], 'D' => %w[A C D])
    end
  end

  context 'when dijkstra_predecessor_distance is called' do
    subject { NetworkX.dijkstra_predecessor_distance(graph, 'A') }

    it do
      is_expected.to eq([{'A' => [], 'B' => ['A'], 'C' => ['A'], 'D' => ['C']},
                         {'A' => 0, 'C' => 2, 'B' => 5, 'D' => 5}])
    end
  end

  context 'when self.all_pairs_dijkstra is called' do
    subject { NetworkX.all_pairs_dijkstra(graph) }

    it do
      is_expected.to eq([['A',
                          [{'A' => 0, 'C' => 2, 'B' => 5, 'D' => 5},
                           {'A' => ['A'],
                            'B' => %w[A B],
                            'C' => %w[A C],
                            'D' => %w[A C D]}]],
                         ['B',
                          [{'B' => 0, 'A' => 5, 'C' => 7, 'D' => 10},
                           {'B' => ['B'],
                            'A' => %w[B A],
                            'C' => %w[B A C],
                            'D' => %w[B A C D]}]],
                         ['C',
                          [{'C' => 0, 'A' => 2, 'D' => 3, 'B' => 7},
                           {'C' => ['C'],
                            'A' => %w[C A],
                            'D' => %w[C D],
                            'B' => %w[C A B]}]],
                         ['D',
                          [{'D' => 0, 'C' => 3, 'A' => 5, 'B' => 10},
                           {'D' => ['D'],
                            'C' => %w[D C],
                            'A' => %w[D C A],
                            'B' => %w[D C A B]}]],
                         ['E', [{'E' => 0}, {'E' => ['E']}]]])
    end
  end

  context 'when dijkstra_predecessor_distance is called' do
    subject { NetworkX.dijkstra_predecessor_distance(graph, 'A') }

    it do
      is_expected.to eq([{'A' => [], 'B' => ['A'], 'C' => ['A'], 'D' => ['C']},
                         {'A' => 0, 'C' => 2, 'B' => 5, 'D' => 5}])
    end
  end

  it 'dijksttra for simple MultiGraph' do
    graph = NetworkX::MultiGraph.new
    graph.add_edges_from([[:a, :b], [:a, :b], [:b, :a], [:a, :c], [:c, :d], [:a, :d], [:c, :e]])
    expect(NetworkX.dijkstra_path_length(graph, :a, :a)).to be 0
    expect(NetworkX.dijkstra_path_length(graph, :a, :b)).to be 1
    expect(NetworkX.dijkstra_path_length(graph, :a, :c)).to be 1
    expect(NetworkX.dijkstra_path_length(graph, :a, :d)).to be 1
    expect(NetworkX.dijkstra_path_length(graph, :a, :e)).to be 2
  end

  it 'dijksttra for MultiGraph' do
    graph = NetworkX::MultiGraph.new
    graph.add_weighted_edges_from([[:a, :b, 20], [:a, :b, 5], [:a, :b, 10]])
    expect(graph.edges).to eq [[:a, :b, 0], [:a, :b, 1], [:a, :b, 2]]
    expect(NetworkX.dijkstra_path_length(graph, :a, :a)).to be 0
    # expect(NetworkX.dijkstra_path_length(graph, :a, :b)).to be 5 # [TODO]
  end

  it 'allpairs_bellmanford_path for MultiGraph' do
    graph = NetworkX::MultiGraph.new
    graph.add_edges_from([[:a, :b], [:a, :b], [:b, :c], [:a, :c]])

    expect(NetworkX.allpairs_bellmanford_path_length(graph)).to eq  [
      [:a, {:a=>0, :b=>1, :c=>1}],
      [:b, {:a=>1, :b=>0, :c=>1}],
      [:c, {:a=>1, :b=>1, :c=>0}]
    ]
    expect(NetworkX.allpairs_bellmanford_path(graph)).to eq  [
      [:a, {:a=>[:a], :b=>[:b, :a], :c=>[:c, :a]}],
      [:b, {:a=>[:a, :b], :b=>[:b], :c=>[:c, :b]}],
      [:c, {:a=>[:a, :c], :b=>[:b, :c], :c=>[:c]}]
    ]
  end

  it 'raise ArgumentError in singlesource_bellmanford' do
    graph = NetworkX::DiGraph.new
    graph.add_node(:a)
    graph.add_node(:x)
    expect{ NetworkX.singlesource_bellmanford(graph, :a, :x) }.to raise_error(ArgumentError)
  end

  it 'bellmanford_path' do
    graph = NetworkX::DiGraph.new
    graph.add_edges_from([[:a, :b],[:b,:c], [:c, :d], [:d, :x], [:c, :x]])
    graph.add_node(:x)

    expect(NetworkX.bellmanford_path(graph, :a, :x)).to eq [:x, :c, :b, :a]
    # [TODO] [:a, :b, :c, :x] ?
  end

  context 'when bellmanford_predecesor_distance is called' do
    subject { NetworkX.bellmanford_predecesor_distance(graph, 'A') }

    it do
      is_expected.to eq([{'A' => [], 'B' => ['A'], 'C' => ['A'], 'D' => ['C']},
                         {'A' => 0, 'C' => 2, 'B' => 5, 'D' => 5}])
    end
  end

  context 'when singlesource_bellmanford is called' do
    subject { NetworkX.singlesource_bellmanford(graph, 'A') }

    it do
      is_expected.to eq([{'A' => 0, 'B' => 5, 'C' => 2, 'D' => 5},
                         {'A' => ['A'], 'B' => %w[B A], 'C' => %w[C A], 'D' => %w[D C A]}])
    end
  end

  context 'when bellmanford_path_length is called' do
    subject { NetworkX.bellmanford_path_length(graph, 'A', 'D') }

    it do
      is_expected.to eq(5)
    end
  end

  context 'when bellmanford_path_length is called' do
    subject { NetworkX.bellmanford_path_length(graph, 'A', 'D') }

    it do
      is_expected.to eq(5)
    end
  end

  context 'when johnson is called' do
    subject { NetworkX.johnson(graph) }

    it do
      is_expected.to eq([['A', {'A' => ['A'], 'B' => %w[A B], 'C' => %w[A C], 'D' => %w[A C D]}],
                         ['B', {'B' => ['B'], 'A' => %w[B A], 'C' => %w[B A C], 'D' => %w[B A C D]}],
                         ['C', {'C' => ['C'], 'A' => %w[C A], 'D' => %w[C D], 'B' => %w[C A B]}],
                         ['D', {'D' => ['D'], 'C' => %w[D C], 'A' => %w[D C A], 'B' => %w[D C A B]}],
                         ['E', {'E' => ['E']}]])
    end
  end
end
