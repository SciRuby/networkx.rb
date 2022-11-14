RSpec.describe NetworkX::Graph do
  subject { graph }

  let(:graph) { described_class.new }

  before do
    graph.add_edge(1, 2)
    graph.add_edge(2, 4)
  end

  context 'when pagerank is called' do
    subject { NetworkX.pagerank(graph, 1 => 0.333, 2 => 0.333, 4 => 0.333) }

    it { is_expected.to eq([0.2567467074324632, 0.4865065851350735, 0.2567467074324632]) }
  end

  it 'Digraph#pagerank2' do
    graph = NetworkX::DiGraph.new
    graph.add_edges([[1, 2], [1, 3], [2, 4], [3, 4], [3, 5], [4, 5], [5, 1]])
    pagerank = NetworkX.pagerank2(graph, alpha: 0.95)
    expect(pagerank[1]).to be_within(0.00001).of(0.26261033194706523)
    expect(pagerank[2]).to be_within(0.00001).of(0.13473925873325307)
    expect(pagerank[3]).to be_within(0.00001).of(0.13473925873325307)
    expect(pagerank[4]).to be_within(0.00001).of(0.20200447126193546)
    expect(pagerank[5]).to be_within(0.00001).of(0.26590667932449313)
  end

  it 'pagerank2' do
    graph = NetworkX::Graph.new
    graph.add_edges([[1, 2], [2, 4]])
    pagerank = NetworkX.pagerank2(graph)
    expect(pagerank[1]).to be_within(0.0001).of(0.2567467074324632)
    expect(pagerank[2]).to be_within(0.0001).of(0.4865065851350735)
    expect(pagerank[4]).to be_within(0.0001).of(0.2567467074324632)
  end

  it 'pagerank2(alpha: 0)' do
    graph = NetworkX::Graph.new
    graph.add_edges([[:a, :b], [:b, :c], [:c, :d], [:d, :a]])
    pagerank = NetworkX.pagerank2(graph, alpha: 0)
    expect(pagerank).to eq({a: 0.25, b: 0.25, c: 0.25, d: 0.25})
  end
end
