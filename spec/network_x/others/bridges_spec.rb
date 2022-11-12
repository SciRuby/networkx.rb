RSpec.describe NetworkX do
  it 'test empty graph has no bridge' do
    graph = NetworkX::Graph.new

    expect(NetworkX.bridges(graph)).to eq []
    expect(NetworkX.number_of_bridges(graph)).to be 0
  end

  it 'test simple graph' do
    graph = NetworkX::Graph.new
    graph.add_nodes_from(1..3)
    graph.add_edge(1, 2)
    graph.add_edge(2, 3)

    expect(NetworkX.bridges(graph)).to eq [[1, 2], [2, 3]]
    expect(NetworkX.number_of_bridges(graph)).to be 2
  end

  # refer to: https://atcoder.jp/contests/abc075/tasks/abc075_c
  it 'test brudges to answer ABC075_C sample#1' do
    n, _m = 7, 7
    edges = [[1, 3], [2, 7], [3, 4], [4, 5], [4, 6], [5, 6], [6, 7]]
    graph = NetworkX::Graph.new
    graph.add_nodes_from(1..n)
    graph.add_edges(edges)

    expect(NetworkX.bridges(graph).size).to be 4
    expect(NetworkX.number_of_bridges(graph)).to be 4
  end

  it 'test brudges to answer ABC075_C sample#2' do
    n, _m = 3, 3
    edges = [[1, 2], [1, 3], [2, 3]]
    graph = NetworkX::Graph.new
    graph.add_nodes_from(1..n)
    graph.add_edges(edges)

    expect(NetworkX.bridges(graph).size).to be 0
  end

  it 'test brudges to answer ABC075_C sample#3' do
    n, _m = 6, 5
    edges = [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6]]
    graph = NetworkX::Graph.new
    graph.add_nodes_from(1..n)
    graph.add_edges(edges)

    expect(NetworkX.bridges(graph).size).to be 5
  end
end
