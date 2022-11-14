RSpec.describe NetworkX::Graph do
  subject { graph }

  let(:graph) { described_class.new }

  before do
    graph.add_edge(1, 2)
    graph.add_edge(2, 4)
    graph.add_edge(1, 4)
    graph.add_edge(5, 6)
    graph.add_edge(7, 6)
    graph.add_edge(5, 7)
  end

  context 'when cliques is called' do
    subject { NetworkX.find_cliques(graph) }

    it { is_expected.to eq([[7, 5, 6], [1, 2, 4]]) }
  end

  it 'number of cliques' do
    graph = NetworkX::Graph.new
    graph.add_edges([[1, 2], [1, 5], [2, 3], [2, 5], [3, 4], [4, 5], [4, 6]])
    expect(NetworkX.number_of_cliques(graph, 1)).to be 1
    expect(NetworkX.number_of_cliques(graph, 2)).to be 2
    expect(NetworkX.number_of_cliques(graph, 3)).to be 2
    expect(NetworkX.number_of_cliques(graph, 4)).to be 3
    expect(NetworkX.number_of_cliques(graph, 5)).to be 2
    expect(NetworkX.number_of_cliques(graph, 6)).to be 1
  end
end
