RSpec.describe NetworkX::Graph do
  it 'pagerank1' do
    graph = NetworkX::Graph.new
    graph.add_edges([[1, 2], [2, 4]])

    pagerank = NetworkX.pagerank1(graph)
    expect(pagerank[0]).to be_within(1e-6).of(0.25675675672536513)
    expect(pagerank[1]).to be_within(1e-6).of(0.4864864865492695)
    expect(pagerank[2]).to be_within(1e-6).of(0.25675675672536513)
  end

  it 'error of pagerank1' do
    graph = NetworkX::Graph.new
    graph.add_edges([[1, 2], [1, 3], [2, 4], [3, 4], [3, 5], [4, 5], [5, 1]])
    init = (1..5).to_h{|i| [i, 0.20] }
    expect{NetworkX.pagerank1(graph, init: init, max_iter: 5)}.to raise_error(ArgumentError)
    expect{NetworkX.pagerank1(graph, eps: 1e-16)}.to raise_error(ArgumentError)
  end

  it 'Digraph#pagerank2' do
    graph = NetworkX::DiGraph.new
    graph.add_edges([[1, 2], [1, 3], [2, 4], [3, 4], [3, 5], [4, 5], [5, 1]])
    pagerank = NetworkX.pagerank2(graph, alpha: 0.95)
    expect(pagerank[1]).to be_within(1e-6).of(0.26261029498162486)
    expect(pagerank[2]).to be_within(1e-6).of(0.13473989208216358)
    expect(pagerank[3]).to be_within(1e-6).of(0.13473989208216358)
    expect(pagerank[4]).to be_within(1e-6).of(0.20200434638512804)
    expect(pagerank[5]).to be_within(1e-6).of(0.2659055744689199)
  end

  it 'pagerank2' do
    graph = NetworkX::Graph.new
    graph.add_edges([[1, 2], [2, 4]])
    pagerank = NetworkX.pagerank2(graph)
    expect(pagerank[1]).to be_within(1e-6).of(0.25675675672536513)
    expect(pagerank[2]).to be_within(1e-6).of(0.4864864865492695)
    expect(pagerank[4]).to be_within(1e-6).of(0.25675675672536513)
  end

  it 'pagerank2(alpha: 0)' do
    graph = NetworkX::Graph.new
    graph.add_edges([[:a, :b], [:b, :c], [:c, :d], [:d, :a]])
    pagerank = NetworkX.pagerank2(graph, alpha: 0)
    expect(pagerank).to eq({a: 0.25, b: 0.25, c: 0.25, d: 0.25})
  end
end
