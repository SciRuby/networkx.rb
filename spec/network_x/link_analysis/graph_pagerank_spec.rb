RSpec.describe NetworkX::Graph do
  it 'Digraph#pagerank' do
    graph = NetworkX::DiGraph.new
    graph.add_edges([[1, 2], [1, 3], [2, 4], [3, 4], [3, 5], [4, 5], [5, 1]])
    pagerank = NetworkX.pagerank(graph, alpha: 0.95, max_iter: 1000)
    expect(pagerank[1]).to be_within(1e-6).of(0.26261029498162486)
    expect(pagerank[2]).to be_within(1e-6).of(0.13473989208216358)
    expect(pagerank[3]).to be_within(1e-6).of(0.13473989208216358)
    expect(pagerank[4]).to be_within(1e-6).of(0.20200434638512804)
    expect(pagerank[5]).to be_within(1e-6).of(0.2659055744689199)
  end

  it 'pagerank' do
    graph = NetworkX::Graph.new
    graph.add_edges([[1, 2], [2, 4]])
    pagerank = NetworkX.pagerank(graph)
    expect(pagerank[1]).to be_within(1e-6).of(0.25675675672536513)
    expect(pagerank[2]).to be_within(1e-6).of(0.4864864865492695)
    expect(pagerank[4]).to be_within(1e-6).of(0.25675675672536513)
  end

  it 'pagerank(alpha: 0)' do
    graph = NetworkX::Graph.new
    graph.add_edges([[:a, :b], [:b, :c], [:c, :d], [:d, :a]])
    pagerank = NetworkX.pagerank(graph, alpha: 0)
    expect(pagerank).to eq({a: 0.25, b: 0.25, c: 0.25, d: 0.25})
  end
end
